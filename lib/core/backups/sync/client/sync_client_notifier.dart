// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/loggers.dart';
import '../../../settings/providers.dart';
import 'sync_service.dart';
import 'types.dart';

const _kLogName = 'Sync Client';

final syncClientProvider =
    NotifierProvider<SyncClientNotifier, SyncClientState>(
      SyncClientNotifier.new,
    );

class SyncClientNotifier extends Notifier<SyncClientState> {
  Timer? _pollTimer;

  @override
  SyncClientState build() {
    ref.onDispose(() => _pollTimer?.cancel());

    final savedAddress = ref.watch(settingsProvider).savedSyncHubAddress;
    return SyncClientState(
      status: SyncClientStatus.idle,
      savedHubAddress: savedAddress,
    );
  }

  Logger get _logger => ref.read(loggerProvider);

  SyncService _getService(String address) =>
      ref.read(syncServiceProvider(address));

  Future<void> stageToHub(String hubAddress) async {
    if (state.isBlocked) return;

    final address = normalizeHubAddress(hubAddress);
    state = state.startConnecting(address);

    final result = await _getService(address).stageToHub(
      existingClientId: state.clientId,
    );

    if (result.isSuccess) {
      await _saveHubAddress(address);
      state = state.onConnected(result.clientId!).onStaged(address);
      startPolling();
      _logger.info(_kLogName, 'Staged to hub, waiting for confirmation');
    } else {
      state = state.onError(result.error!);
      _logger.error(_kLogName, result.error!);
    }
  }

  Future<void> pullFromHub() async {
    final address = state.currentHubAddress ?? state.savedHubAddress;
    if (address == null) {
      state = state.onError('No hub address configured');
      return;
    }

    state = state.startPulling();

    final result = await _getService(address).pullFromHub();

    if (result.isSuccess) {
      state = state.onPullComplete();
      _logger.info(_kLogName, 'Pull completed');
    } else {
      state = state.onError(result.error!);
      _logger.error(_kLogName, result.error!);
    }
  }

  Future<bool> checkSyncStatus() async {
    final address = state.currentHubAddress ?? state.savedHubAddress;
    if (address == null) return false;

    final result = await _getService(address).checkStatus();

    if (result.isFailure) {
      _logger.warn(_kLogName, 'Poll failed');
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

  Future<void> _saveHubAddress(String address) async {
    final settings = ref.read(settingsProvider);
    await ref
        .read(settingsNotifierProvider.notifier)
        .updateSettings(settings.copyWith(savedSyncHubAddress: address));
  }
}
