// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/info/device_info.dart';
import '../../../../foundation/loggers.dart';
import '../../../settings/providers.dart';
import '../../sources/providers.dart';
import 'sync_client.dart';
import 'sync_service.dart';
import 'types.dart';

const _kLogName = 'Sync Client';

final syncClientProvider =
    AutoDisposeNotifierProvider<SyncClientNotifier, SyncClientState>(
      SyncClientNotifier.new,
    );

class SyncClientNotifier extends AutoDisposeNotifier<SyncClientState> {
  SyncClient? _client;
  SyncService? _service;

  @override
  SyncClientState build() {
    ref.onDispose(() {
      _client?.dispose();
      _client = null;
      _service = null;
    });

    final savedAddress = ref.watch(settingsProvider).savedSyncHubAddress;
    return SyncClientState(
      status: SyncClientStatus.idle,
      savedHubAddress: savedAddress,
    );
  }

  Logger get _logger => ref.read(loggerProvider);

  SyncService _createService(String address) {
    // Dispose existing client if address changed
    if (_client != null && _client!.baseUrl != address) {
      _client!.dispose();
      _client = null;
      _service = null;
    }

    if (_service != null) return _service!;

    _client = SyncClient(
      baseUrl: address,
      onSyncConfirmed: _handleSyncConfirmed,
      onSyncReset: _handleSyncReset,
      onDisconnected: _handleDisconnected,
      onError: _handleError,
    );

    _service = SyncService(
      client: _client!,
      registry: ref.read(backupRegistryProvider),
      deviceName: ref.read(deviceInfoProvider).deviceName ?? 'Unknown',
    );

    return _service!;
  }

  void _handleSyncConfirmed() {
    _logger.info(_kLogName, 'Hub confirmed sync, starting pull');
    pullFromHub();
  }

  void _handleSyncReset() {
    _logger.info(_kLogName, 'Hub reset sync');
    state = state.toIdle();
  }

  void _handleDisconnected() {
    _logger.warn(_kLogName, 'Disconnected from hub');
    if (state.status == SyncClientStatus.waitingForConfirmation) {
      state = state.copyWith(
        status: SyncClientStatus.hubUnreachable,
        errorMessage: () => 'Connection to hub lost',
      );
    }
  }

  void _handleError(String message) {
    _logger.error(_kLogName, message);
  }

  Future<void> stageToHub(String hubAddress) async {
    if (state.isBlocked) return;

    final address = normalizeHubAddress(hubAddress);
    state = state.startConnecting(address);

    final service = _createService(address);
    final result = await service.stageToHub(
      existingClientId: state.clientId,
    );

    if (result.isSuccess) {
      await _saveHubAddress(address);
      state = state.onConnected(result.clientId!).onStaged(address);
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

    final service = _createService(address);
    final result = await service.pullFromHub(clientId: state.clientId);

    if (result.isSuccess) {
      state = state.onPullComplete();
      _logger.info(_kLogName, 'Pull completed');
    } else {
      state = state.onError(result.error!);
      _logger.error(_kLogName, result.error!);
    }
  }

  void reset() {
    _client?.disconnect();
    state = state.toIdle();
  }

  void retryConnection() {
    final address = state.currentHubAddress ?? state.savedHubAddress;
    if (address != null) {
      stageToHub(address);
    }
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
