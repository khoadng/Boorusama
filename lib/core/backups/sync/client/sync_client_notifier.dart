// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/loggers.dart';
import '../../../settings/providers.dart';
import '../../sources/providers.dart';
import 'sync_client.dart';
import 'sync_client_repo.dart';
import 'sync_service.dart';
import 'types.dart';

const _kLogName = 'Sync Client';

final syncClientRepoProvider = Provider.family<SyncClientRepo, String>((
  ref,
  address,
) {
  final client = SyncClient(baseUrl: address);
  final service = SyncService(
    client: client,
    registry: ref.watch(backupRegistryProvider),
    deviceName: ref.watch(deviceInfoProvider).deviceName ?? 'Unknown',
  );

  ref.onDispose(service.dispose);

  return service;
});

final syncClientEventsProvider = StreamProvider.autoDispose
    .family<SyncEvent, String>((ref, address) {
      final repo = ref.watch(syncClientRepoProvider(address));
      return repo.events;
    });

final syncClientProvider =
    AutoDisposeNotifierProvider.family<
      SyncClientNotifier,
      SyncClientState,
      String
    >(SyncClientNotifier.new);

class SyncClientNotifier
    extends AutoDisposeFamilyNotifier<SyncClientState, String> {
  @override
  SyncClientState build(String arg) {
    ref.listen(syncClientEventsProvider(arg), (_, next) {
      next.whenData(_handleEvent);
    });

    return const SyncClientState(
      status: SyncClientStatus.idle,
    );
  }

  String get _address => arg;

  Logger get _logger => ref.read(loggerProvider);

  SyncClientRepo get _repo => ref.read(syncClientRepoProvider(_address));

  void _handleEvent(SyncEvent event) {
    switch (event) {
      case SyncConfirmedEvent():
        _logger.info(_kLogName, 'Hub confirmed sync, starting pull');
        pullFromHub();

      case SyncResetEvent():
        _logger.info(_kLogName, 'Hub reset sync');
        state = state.toIdle();

      case SyncDisconnectedEvent():
        _logger.warn(_kLogName, 'Disconnected from hub');
        if (state.status == SyncClientStatus.waitingForConfirmation) {
          state = state.copyWith(
            status: SyncClientStatus.hubUnreachable,
            errorMessage: () => 'Connection to hub lost',
          );
        }

      case SyncErrorEvent(:final message):
        _logger.error(_kLogName, message);
    }
  }

  Future<void> stageToHub() async {
    if (state.isBlocked) return;

    state = state.startConnecting();

    final result = await _repo.stageToHub(existingClientId: state.clientId);

    if (result.isSuccess) {
      await _saveHubAddress();
      state = state.onConnected(result.clientId!).onStaged();
      _logger.info(_kLogName, 'Staged to hub, waiting for confirmation');
    } else {
      state = state.onError(result.error!);
      _logger.error(_kLogName, result.error!);
    }
  }

  Future<void> pullFromHub() async {
    state = state.startPulling();

    final result = await _repo.pullFromHub(clientId: state.clientId);

    if (result.isSuccess) {
      state = state.onPullComplete();
      _logger.info(_kLogName, 'Pull completed');
    } else {
      state = state.onError(result.error!);
      _logger.error(_kLogName, result.error!);
    }
  }

  void reset() {
    _repo.disconnect();
    ref.invalidateSelf();
  }

  void retryConnection() {
    stageToHub();
  }

  Future<void> _saveHubAddress() async {
    final settings = ref.read(settingsProvider);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(settings.copyWith(savedSyncHubAddress: _address));
  }
}
