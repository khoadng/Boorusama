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
    if (state.isBlocked) return;

    final normalizedAddress = _normalizeAddress(hubAddress);
    _client?.dispose();
    _client = SyncClient(baseUrl: normalizedAddress);

    state = state.startConnecting(normalizedAddress);

    // Check hub health
    final healthResult = await _client!.checkHealth();
    if (healthResult.isFailure) {
      state = state.onError(healthResult.error!);
      _logger.error(_kLogName, healthResult.error!);
      return;
    }

    // Connect to hub
    final deviceName = ref.read(deviceInfoProvider).deviceName ?? 'Unknown';
    final connectResult = await _client!.connect(
      existingClientId: state.clientId,
      deviceName: deviceName,
    );

    if (connectResult.isFailure) {
      state = state.onError(connectResult.error!);
      _logger.error(_kLogName, connectResult.error!);
      return;
    }

    state = state.onConnected(connectResult.data!.clientId);
    _logger.info(_kLogName, 'Connected as ${connectResult.data!.clientId}');

    // Stage data
    final stageSuccess = await _stageAllSources();
    if (!stageSuccess) {
      state = state.onError('Failed to stage data');
      _logger.error(_kLogName, 'Failed to stage data');
      return;
    }

    await _saveHubAddress(normalizedAddress);
    state = state.onStaged(normalizedAddress);

    startPolling();
    _logger.info(_kLogName, 'Data staged, waiting for confirmation');
  }

  Future<void> pullFromHub() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) {
      state = state.onError('No hub address configured');
      return;
    }

    _client ??= SyncClient(baseUrl: hubAddress);
    state = state.startPulling();

    final statusResult = await _client!.checkSyncStatus();
    if (statusResult.isFailure) {
      state = state.onError(statusResult.error!);
      return;
    }

    if (!statusResult.data!.canPull) {
      state = state.onError('Hub sync not confirmed yet');
      return;
    }

    await _pullAllSources();
    state = state.onPullComplete();
    _logger.info(_kLogName, 'Pull completed');
  }

  Future<bool> checkSyncStatus() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) return false;

    _client ??= SyncClient(baseUrl: hubAddress);

    final result = await _client!.checkSyncStatus();

    if (result.isFailure) {
      _logger.warn(
        _kLogName,
        'Poll failed (${state.consecutiveFailures + 1}/${SyncClientState.maxFailuresBeforeUnreachable})',
      );
      state = state.onPollFailure();
      return false;
    }

    state = state.onPollSuccess();

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
    state = state.toIdle();
  }

  void retryConnection() {
    state = state.onRetry();
  }

  void clearSavedAddress() {
    ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(ref.read(settingsProvider).copyWith());
    state = state.withoutSavedAddress();
  }

  // Private helpers

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
