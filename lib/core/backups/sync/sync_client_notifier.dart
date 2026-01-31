// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../settings/providers.dart';
import '../sources/providers.dart';
import '../types/backup_registry.dart';
import 'sync_client.dart';
import 'types.dart';

const _kLogName = 'Sync Client';

final syncClientProvider =
    NotifierProvider<SyncClientNotifier, SyncClientState>(
      SyncClientNotifier.new,
    );

class SyncClientNotifier extends Notifier<SyncClientState> {
  Timer? _pollTimer;
  SyncClient? _client;

  static const _maxFailuresBeforeUnreachable = 3;

  @override
  SyncClientState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
      _client?.dispose();
    });

    final savedAddress = ref.watch(settingsProvider).savedSyncHubAddress;
    return SyncClientState(
      status: SyncClientStatus.idle,
      savedHubAddress: savedAddress,
    );
  }

  Logger get _logger => ref.read(loggerProvider);
  BackupRegistry get _registry => ref.read(backupRegistryProvider);

  Future<void> stageToHub(String hubAddress) async {
    if (state.status == SyncClientStatus.staging ||
        state.status == SyncClientStatus.waitingForConfirmation ||
        state.status == SyncClientStatus.pulling) {
      return;
    }

    final normalizedAddress = _normalizeAddress(hubAddress);
    _client?.dispose();
    _client = SyncClient(baseUrl: normalizedAddress);

    state = state.copyWith(
      status: SyncClientStatus.connecting,
      currentHubAddress: () => normalizedAddress,
      consecutiveFailures: 0,
      errorMessage: () => null,
    );

    // Check hub health
    final healthResult = await _client!.checkHealth();
    if (healthResult.isFailure) {
      _handleError(healthResult.error!);
      return;
    }

    // Connect to hub
    final deviceName = ref.read(deviceInfoProvider).deviceName ?? 'Unknown';
    final connectResult = await _client!.connect(
      existingClientId: state.clientId,
      deviceName: deviceName,
    );

    if (connectResult.isFailure) {
      _handleError(connectResult.error!);
      return;
    }

    state = state.copyWith(
      status: SyncClientStatus.staging,
      clientId: () => connectResult.data!.clientId,
    );

    _logger.info(_kLogName, 'Connected as ${connectResult.data!.clientId}');

    // Stage data
    final stageSuccess = await _stageAllSources();
    if (!stageSuccess) {
      _handleError('Failed to stage data');
      return;
    }

    // Save hub address and update state
    await _saveHubAddress(normalizedAddress);

    state = state.copyWith(
      status: SyncClientStatus.waitingForConfirmation,
      savedHubAddress: () => normalizedAddress,
    );

    startPolling();
    _logger.info(_kLogName, 'Data staged, waiting for confirmation');
  }

  Future<void> pullFromHub() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) {
      _handleError('No hub address configured');
      return;
    }

    _client ??= SyncClient(baseUrl: hubAddress);
    state = state.copyWith(status: SyncClientStatus.pulling);

    // Check if we can pull
    final statusResult = await _client!.checkSyncStatus();
    if (statusResult.isFailure) {
      _handleError(statusResult.error!);
      return;
    }

    if (!statusResult.data!.canPull) {
      state = state.copyWith(
        status: SyncClientStatus.waitingForConfirmation,
        errorMessage: () => 'Hub sync not confirmed yet',
      );
      return;
    }

    // Pull data for each source
    await _pullAllSources();

    state = state.copyWith(status: SyncClientStatus.completed);
    _logger.info(_kLogName, 'Pull completed');
  }

  Future<bool> checkSyncStatus() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) return false;

    _client ??= SyncClient(baseUrl: hubAddress);

    final result = await _client!.checkSyncStatus();

    if (result.isFailure) {
      final failures = state.consecutiveFailures + 1;
      _logger.warn(
        _kLogName,
        'Poll failed ($failures/$_maxFailuresBeforeUnreachable)',
      );

      if (failures >= _maxFailuresBeforeUnreachable &&
          state.status == SyncClientStatus.waitingForConfirmation) {
        state = state.copyWith(
          status: SyncClientStatus.hubUnreachable,
          consecutiveFailures: failures,
          errorMessage: () => 'Hub is not responding',
        );
      } else {
        state = state.copyWith(consecutiveFailures: failures);
      }
      return false;
    }

    // Success - reset failures
    if (state.status == SyncClientStatus.hubUnreachable) {
      state = state.copyWith(
        status: SyncClientStatus.waitingForConfirmation,
        consecutiveFailures: 0,
        errorMessage: () => null,
      );
    } else if (state.consecutiveFailures > 0) {
      state = state.copyWith(consecutiveFailures: 0);
    }

    if (result.data!.canPull &&
        state.status == SyncClientStatus.waitingForConfirmation) {
      await pullFromHub();
    }

    return result.data!.canPull;
  }

  void startPolling({Duration interval = const Duration(seconds: 3)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) async {
      if (state.status == SyncClientStatus.waitingForConfirmation ||
          state.status == SyncClientStatus.hubUnreachable) {
        await checkSyncStatus();
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void reset() {
    stopPolling();
    _client?.dispose();
    _client = null;
    state = state.copyWith(
      status: SyncClientStatus.idle,
      clientId: () => null,
      consecutiveFailures: 0,
      errorMessage: () => null,
      lastSyncStats: () => null,
    );
  }

  void retryConnection() {
    if (state.status != SyncClientStatus.hubUnreachable) return;

    state = state.copyWith(
      status: SyncClientStatus.waitingForConfirmation,
      consecutiveFailures: 0,
      errorMessage: () => null,
    );
  }

  void clearSavedAddress() {
    ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(ref.read(settingsProvider).copyWith());
    state = state.copyWith(savedHubAddress: () => null);
  }

  // Private helpers

  void _handleError(String message) {
    _logger.error(_kLogName, message);
    state = state.copyWith(
      status: SyncClientStatus.error,
      errorMessage: () => message,
    );
  }

  String _normalizeAddress(String address) {
    var normalized = address.trim();
    if (!normalized.startsWith('http://') &&
        !normalized.startsWith('https://')) {
      normalized = 'http://$normalized';
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }

  Future<void> _saveHubAddress(String address) async {
    final settings = ref.read(settingsProvider);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(settings.copyWith(savedSyncHubAddress: address));
  }

  Future<bool> _stageAllSources() async {
    final clientId = state.clientId;
    if (clientId == null) return false;

    var stagedCount = 0;

    for (final source in _registry.getAllSources()) {
      if (source.capabilities.sync == null) continue;

      try {
        final mockRequest = shelf.Request(
          'GET',
          Uri.parse('http://localhost/'),
        );
        final exportResponse = await source.capabilities.server.export(
          mockRequest,
        );
        final exportData = await exportResponse.readAsString();
        final parsedData = jsonDecode(exportData);

        final data = switch (parsedData) {
          {'data': final List data} => data,
          final List data => data,
          _ => <dynamic>[],
        };

        final result = await _client!.stageData(
          clientId: clientId,
          sourceId: source.id,
          data: data,
        );

        if (result.isSuccess) {
          stagedCount++;
          _logger.info(
            _kLogName,
            'Staged ${data.length} items for ${source.id}',
          );
        }
      } catch (e) {
        _logger.error(_kLogName, 'Stage failed for ${source.id}: $e');
      }
    }

    return stagedCount > 0;
  }

  Future<void> _pullAllSources() async {
    for (final source in _registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        final result = await _client!.pullData(source.id);
        if (result.isFailure || result.data!.data.isEmpty) continue;

        await syncCapability.importResolved(result.data!.data);
        _logger.info(
          _kLogName,
          'Pulled ${result.data!.data.length} items for ${source.id}',
        );
      } catch (e) {
        _logger.error(_kLogName, 'Pull failed for ${source.id}: $e');
      }
    }
  }
}
