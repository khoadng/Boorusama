// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/info/package_info.dart';
import '../../../../foundation/loggers.dart';
import '../../../../foundation/networking.dart';
import '../../sources/providers.dart';
import '../types.dart';
import 'sync_hub_server.dart';
import 'sync_hub_service.dart';

const _kHubServerName = 'Sync Hub';

final syncHubServiceProvider = Provider.autoDispose<SyncHubService>((ref) {
  return SyncHubService(registry: ref.watch(backupRegistryProvider));
});

final syncHubProvider = NotifierProvider<SyncHubNotifier, SyncHubState>(
  SyncHubNotifier.new,
);

class SyncHubNotifier extends Notifier<SyncHubState> {
  SyncHubServer? _server;

  @override
  SyncHubState build() {
    ref.onDispose(() async {
      await _server?.stop();
    });
    return const SyncHubState.initial();
  }

  Logger get _logger => ref.read(loggerProvider);
  SyncHubService get _service => ref.read(syncHubServiceProvider);

  Future<void> startHub({SyncHubConfig? config}) async {
    if (state.isRunning) return;

    final hubConfig = config ?? state.config;
    state = state.copyWith(config: hubConfig);

    try {
      final address = await ref.read(localIPAddressProvider.future);
      if (address == null) {
        _logger.error(_kHubServerName, 'Failed to get local IP address');
        return;
      }

      _server = SyncHubServer(
        stateGetter: () => state,
        onConnect: _handleConnect,
        onStage: _handleStage,
        onExport: _handleExport,
      );

      final serverUrl = await _server!.start(
        address: address,
        port: hubConfig.port ?? 0,
      );

      if (serverUrl == null) {
        _logger.error(_kHubServerName, 'Failed to start server');
        return;
      }

      state = state.onStarted(serverUrl);
      _logger.info(_kHubServerName, 'Hub running on $serverUrl');

      if (hubConfig.enableDiscovery) {
        final deviceName =
            ref.read(deviceInfoProvider).deviceName ?? 'Sync Hub';
        final appVersion = ref.read(packageInfoProvider).version;
        await _server!.startBroadcast(
          deviceName: deviceName,
          appVersion: appVersion,
        );
      }
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to start hub: $e');
      state = state.copyWith(isRunning: false);
    }
  }

  Future<void> stopHub() async {
    try {
      await _server?.stop();
      _server = null;
      state = const SyncHubState.initial();
      _logger.info(_kHubServerName, 'Hub stopped');
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to stop hub: $e');
    }
  }

  Future<ConnectResponse> _handleConnect(ConnectRequest request) async {
    final clientId = request.clientId ?? _service.generateClientId();

    state = _service.handleConnect(
      state,
      ConnectRequest(
        clientId: clientId,
        deviceName: request.deviceName,
        clientAddress: request.clientAddress,
      ),
    );

    _logger.info(
      _kHubServerName,
      'Client connected: $clientId (${request.deviceName})',
    );

    return ConnectResponse(clientId: clientId, phase: state.phase);
  }

  Future<StageResponse> _handleStage(
    String sourceId,
    StageRequest request,
  ) async {
    final source = ref.read(backupRegistryProvider).getSource(sourceId);
    if (source == null) {
      return StageResponse.failure('Source not found: $sourceId');
    }

    final (newState, stagedCount) = _service.handleStage(
      state,
      sourceId,
      request,
    );
    state = newState;

    _logger.info(
      _kHubServerName,
      'Staged $stagedCount items for $sourceId from ${request.clientId}',
    );

    return StageResponse.success(stagedCount);
  }

  Future<ExportResponse> _handleExport(String sourceId) =>
      _service.exportSource(sourceId);

  Future<void> startReview() async {
    state = await _service.stageHubOwnData(state);

    if (state.stagedData.isEmpty) return;

    final conflicts = _service.detectConflicts(state);
    state = state.onReviewStarted(conflicts);
  }

  void resolveConflict(int conflictIndex, ConflictResolution resolution) {
    state = state.onConflictResolved(conflictIndex, resolution);
  }

  void resolveAllConflicts(ConflictResolution resolution) {
    state = state.onAllConflictsResolved(resolution);
  }

  Future<void> confirmSync() async {
    if (state.hasUnresolvedConflicts) return;

    final resolvedData = _service.mergeData(state);
    await _service.importResolvedData(resolvedData);

    state = state.onSyncConfirmed(resolvedData);
    _logger.info(_kHubServerName, 'Sync confirmed, clients can now pull');
  }

  void resetSync() {
    state = state.onReset();
  }
}
