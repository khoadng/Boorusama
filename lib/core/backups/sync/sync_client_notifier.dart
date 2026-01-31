// Dart imports:
import 'dart:async';
import 'dart:convert';

// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart' as shelf;

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/loggers.dart';
import '../../settings/providers.dart';
import '../sources/providers.dart';
import '../types/backup_registry.dart';
import 'types.dart';

const _kClientName = 'Sync Client';

final syncClientProvider =
    NotifierProvider<SyncClientNotifier, SyncClientState>(
      SyncClientNotifier.new,
    );

class SyncClientNotifier extends Notifier<SyncClientState> {
  String? _clientId;
  Timer? _pollTimer;
  int _consecutiveFailures = 0;
  static const _maxFailuresBeforeUnreachable = 3;

  @override
  SyncClientState build() {
    ref.onDispose(() {
      _pollTimer?.cancel();
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

    _consecutiveFailures = 0;
    final normalizedAddress = _normalizeAddress(hubAddress);

    state = state.copyWith(
      status: SyncClientStatus.connecting,
      currentHubAddress: () => normalizedAddress,
      errorMessage: () => null,
    );

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: normalizedAddress,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      await _checkHubHealth(dio);
      await _connectToHub(dio);
      await _saveHubAddress(normalizedAddress);

      state = state.copyWith(status: SyncClientStatus.staging);
      await _stageDataToHub(dio);

      state = state.copyWith(
        status: SyncClientStatus.waitingForConfirmation,
        savedHubAddress: () => normalizedAddress,
      );

      // Automatically start polling for confirmation
      startPolling();

      _logger.info(
        _kClientName,
        'Data staged to hub, waiting for confirmation (polling started)',
      );
    } catch (e) {
      _logger.error(_kClientName, 'Staging failed: $e');
      state = state.copyWith(
        status: SyncClientStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  Future<void> pullFromHub() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) {
      state = state.copyWith(
        status: SyncClientStatus.error,
        errorMessage: () => 'No hub address configured',
      );
      return;
    }

    state = state.copyWith(status: SyncClientStatus.pulling);

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: hubAddress,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      final statusResponse = await dio.get('/sync/status');
      final canPull = statusResponse.data['canPull'] as bool? ?? false;

      if (!canPull) {
        state = state.copyWith(
          status: SyncClientStatus.waitingForConfirmation,
          errorMessage: () => 'Hub sync not confirmed yet',
        );
        return;
      }

      await _pullResolvedData(dio);

      state = state.copyWith(
        status: SyncClientStatus.completed,
      );

      _logger.info(_kClientName, 'Pull completed successfully');
    } catch (e) {
      _logger.error(_kClientName, 'Pull failed: $e');
      state = state.copyWith(
        status: SyncClientStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  Future<bool> checkSyncStatus() async {
    final hubAddress = state.currentHubAddress ?? state.savedHubAddress;
    if (hubAddress == null) return false;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: hubAddress,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      final response = await dio.get('/sync/status');
      final canPull = response.data['canPull'] as bool? ?? false;

      // Reset failure count on successful connection
      _consecutiveFailures = 0;

      // If we were in hubUnreachable state, go back to waiting
      if (state.status == SyncClientStatus.hubUnreachable) {
        state = state.copyWith(
          status: SyncClientStatus.waitingForConfirmation,
          errorMessage: () => null,
        );
      }

      if (canPull && state.status == SyncClientStatus.waitingForConfirmation) {
        await pullFromHub();
      }

      return canPull;
    } catch (e) {
      _consecutiveFailures++;

      _logger.warn(
        _kClientName,
        'Poll failed ($_consecutiveFailures/$_maxFailuresBeforeUnreachable): $e',
      );

      if (_consecutiveFailures >= _maxFailuresBeforeUnreachable &&
          state.status == SyncClientStatus.waitingForConfirmation) {
        state = state.copyWith(
          status: SyncClientStatus.hubUnreachable,
          errorMessage: () =>
              'Hub is not responding. It may have stopped or disconnected.',
        );
      }

      return false;
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 3)}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(interval, (_) async {
      // Keep polling when waiting or when hub unreachable (for auto-recovery)
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

  Future<void> _checkHubHealth(Dio dio) async {
    try {
      await dio.get('/health');
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw Exception(
          'Cannot connect to hub. Check the address and ensure the hub is running.',
        );
      }
      rethrow;
    }
  }

  Future<void> _connectToHub(Dio dio) async {
    final deviceName = ref.read(deviceInfoProvider).deviceName ?? 'Unknown';

    _logger.info(
      _kClientName,
      'Connecting to hub with deviceName: $deviceName',
    );

    final response = await dio.post(
      '/connect',
      data: jsonEncode({
        'clientId': _clientId,
        'deviceName': deviceName,
      }),
      options: Options(contentType: 'application/json'),
    );

    _logger.info(
      _kClientName,
      'Connect response: ${response.statusCode} - ${response.data}',
    );

    if (response.statusCode == 200) {
      _clientId = response.data['clientId'] as String?;
      _logger.info(_kClientName, 'Connected to hub as $_clientId');

      if (_clientId == null) {
        throw Exception('Hub did not return a clientId');
      }
    } else {
      throw Exception('Failed to connect to hub: ${response.statusCode}');
    }
  }

  Future<void> _stageDataToHub(Dio dio) async {
    var stagedCount = 0;

    for (final source in _registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) {
        _logger.info(
          _kClientName,
          'Skipping ${source.id} - no sync capability',
        );
        continue;
      }

      try {
        _logger.info(_kClientName, 'Getting export data for ${source.id}...');

        // Create a proper shelf.Request for the export function
        final mockRequest = shelf.Request(
          'GET',
          Uri.parse('http://localhost/'),
        );
        final exportResponse = await source.capabilities.server.export(
          mockRequest,
        );
        final exportData = await exportResponse.readAsString();

        _logger.info(
          _kClientName,
          'Export data length for ${source.id}: ${exportData.length}',
        );

        final parsedData = jsonDecode(exportData);
        final data = switch (parsedData) {
          {'data': final List data} => data,
          final List data => data,
          _ => <dynamic>[],
        };

        _logger.info(
          _kClientName,
          'Sending ${data.length} items to hub for ${source.id}...',
        );

        final response = await dio.post(
          '/stage/${source.id}',
          data: jsonEncode({
            'clientId': _clientId,
            'data': data,
          }),
          options: Options(contentType: 'application/json'),
        );

        _logger.info(
          _kClientName,
          'Stage response for ${source.id}: ${response.statusCode} - ${response.data}',
        );

        stagedCount++;
      } catch (e, st) {
        _logger.error(_kClientName, 'Stage failed for ${source.id}: $e\n$st');
      }
    }

    _logger.info(_kClientName, 'Total sources staged: $stagedCount');
  }

  Future<void> _pullResolvedData(Dio dio) async {
    for (final source in _registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        final response = await dio.get('/pull/${source.id}');
        if (response.statusCode != 200) continue;

        final data = response.data['data'] as List<dynamic>?;
        if (data == null || data.isEmpty) continue;

        final preparation = await source.capabilities.server.prepareImport(
          dio.options.baseUrl,
          null,
        );
        await preparation.executeImport();

        _logger.info(
          _kClientName,
          'Pulled ${data.length} items for ${source.id}',
        );
      } catch (e) {
        _logger.error(_kClientName, 'Pull failed for ${source.id}: $e');
      }
    }
  }

  Future<void> _saveHubAddress(String address) async {
    final settings = ref.read(settingsProvider);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(
          settings.copyWith(savedSyncHubAddress: address),
        );
  }

  void reset() {
    stopPolling();
    _consecutiveFailures = 0;
    state = state.copyWith(
      status: SyncClientStatus.idle,
      errorMessage: () => null,
      lastSyncStats: () => null,
    );
  }

  /// Retry connecting to the hub after it was unreachable
  void retryConnection() {
    if (state.status != SyncClientStatus.hubUnreachable) return;

    _consecutiveFailures = 0;
    state = state.copyWith(
      status: SyncClientStatus.waitingForConfirmation,
      errorMessage: () => null,
    );
  }

  void clearSavedAddress() {
    ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(
          ref.read(settingsProvider).copyWith(),
        );
    state = state.copyWith(savedHubAddress: () => null);
  }
}
