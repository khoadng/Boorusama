// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/info/package_info.dart';
import '../../../../foundation/loggers.dart';
import '../../../../foundation/networking.dart';
import '../../sources/providers.dart';
import 'sync_hub_server.dart';
import 'sync_hub_service.dart';
import 'types.dart';

const _kHubServerName = 'Sync Hub';

final syncHubServiceProvider = Provider<SyncHubService>((ref) {
  return SyncHubService(registry: ref.watch(backupRegistryProvider));
});

final syncHubServerProvider = StateProvider<SyncHubServer?>((ref) => null);

final syncHubEventsProvider = StreamProvider<SyncHubEvent>((ref) {
  final server = ref.watch(syncHubServerProvider);
  if (server == null) return const Stream.empty();
  return server.events;
});

final syncHubProvider = NotifierProvider<SyncHubNotifier, SyncHubState>(
  SyncHubNotifier.new,
);

class SyncHubNotifier extends Notifier<SyncHubState> {
  @override
  SyncHubState build() {
    ref.listen(syncHubEventsProvider, (_, next) {
      next.whenData(_handleEvent);
    });

    ref.onDispose(() async {
      final server = ref.read(syncHubServerProvider);
      server?.dispose();
      await server?.stop();
    });

    return const SyncHubState.initial();
  }

  Logger get _logger => ref.read(loggerProvider);
  SyncHubService get _service => ref.read(syncHubServiceProvider);
  SyncHubServer? get _server => ref.read(syncHubServerProvider);

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

      final server = SyncHubServer(stateGetter: () => state);
      ref.read(syncHubServerProvider.notifier).state = server;

      final serverUrl = await server.start(
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
        await server.startBroadcast(
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
      final server = ref.read(syncHubServerProvider);
      server?.dispose();
      await server?.stop();
      ref.read(syncHubServerProvider.notifier).state = null;
      state = const SyncHubState.initial();
      _logger.info(_kHubServerName, 'Hub stopped');
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to stop hub: $e');
    }
  }

  void _handleEvent(SyncHubEvent event) {
    switch (event) {
      case ClientConnectedEvent():
        state = _service.handleConnect(state, event);
        _logger.info(
          _kHubServerName,
          'Client connected: ${event.clientId} (${event.deviceName})',
        );

      case ClientDisconnectedEvent():
        final client = state.connectedClients
            .where((c) => c.id == event.clientId)
            .firstOrNull;
        if (client == null) return;

        state = state.copyWith(
          connectedClients: state.connectedClients
              .where((c) => c.id != event.clientId)
              .toList(),
        );
        _logger.info(
          _kHubServerName,
          'Client disconnected: ${event.clientId} (${client.deviceName})',
        );

      case StageBeginEvent():
        state = _service.handleStageBegin(state, event);
        _logger.info(
          _kHubServerName,
          'Client ${event.clientId} starting staging: ${event.expectedSources.join(", ")}',
        );

      case StageDataEvent():
        state = _service.handleStage(state, event);
        _logger.info(
          _kHubServerName,
          'Staged ${event.data.length} items for ${event.sourceId} from ${event.clientId}',
        );

      case StageCompleteEvent():
        state = _service.handleStageComplete(state, event.clientId);
        _logger.info(
          _kHubServerName,
          'Client ${event.clientId} completed staging',
        );

      case PullCompleteEvent():
        state = _service.handlePullComplete(state, event.clientId);

        final client = state.connectedClients
            .where((c) => c.id == event.clientId)
            .firstOrNull;
        if (client != null) {
          _logger.info(
            _kHubServerName,
            'Client ${event.clientId} (${client.deviceName}) completed pull',
          );
        }

        if (state.phase == SyncHubPhase.completed) {
          _logger.info(
            _kHubServerName,
            'All clients have pulled - sync complete',
          );
        }

      case ExportRequestEvent():
        // Export is handled directly by server via HTTP
        break;
    }
  }

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
    _server?.notifySyncConfirmed();
    _logger.info(_kHubServerName, 'Sync confirmed, clients can now pull');
  }

  void resetSync() {
    state = state.onReset();
    _server?.notifySyncReset();
  }
}
