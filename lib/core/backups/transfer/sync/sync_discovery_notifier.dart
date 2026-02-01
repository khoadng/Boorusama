// Dart imports:
import 'dart:async';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../servers/discovery_client.dart';
import '../../types.dart';

enum SyncDiscoveryStatus {
  idle,
  discovering,
  hubFound,
  noHubFound,
}

class SyncDiscoveryState extends Equatable {
  const SyncDiscoveryState({
    required this.status,
    this.discoveredHubs = const [],
    this.error,
  });

  const SyncDiscoveryState.initial()
    : status = SyncDiscoveryStatus.idle,
      discoveredHubs = const [],
      error = null;

  final SyncDiscoveryStatus status;
  final List<DiscoveredService> discoveredHubs;
  final String? error;

  SyncDiscoveryState copyWith({
    SyncDiscoveryStatus? status,
    List<DiscoveredService>? discoveredHubs,
    String? Function()? error,
  }) => SyncDiscoveryState(
    status: status ?? this.status,
    discoveredHubs: discoveredHubs ?? this.discoveredHubs,
    error: error != null ? error() : this.error,
  );

  @override
  List<Object?> get props => [status, discoveredHubs, error];
}

class SyncDiscoveryNotifier extends Notifier<SyncDiscoveryState> {
  DiscoveryClient? _discoveryClient;
  Timer? _discoveryTimer;

  static const _discoveryTimeout = Duration(seconds: 3);

  @override
  SyncDiscoveryState build() => const SyncDiscoveryState.initial();

  Future<void> startDiscovery() async {
    if (state.status == SyncDiscoveryStatus.discovering) return;

    state = state.copyWith(
      status: SyncDiscoveryStatus.discovering,
      discoveredHubs: [],
      error: () => null,
    );

    _discoveryClient = DiscoveryClient(
      onServiceResolved: _handleServiceResolved,
      onServiceLost: _handleServiceLost,
      onError: (message) {
        state = state.copyWith(error: () => message);
      },
    );

    try {
      await _discoveryClient?.startDiscovery();

      _discoveryTimer = Timer(_discoveryTimeout, () {
        if (state.discoveredHubs.isEmpty) {
          state = state.copyWith(status: SyncDiscoveryStatus.noHubFound);
        }
      });
    } catch (e) {
      state = state.copyWith(
        status: SyncDiscoveryStatus.noHubFound,
        error: () => e.toString(),
      );
    }
  }

  void _handleServiceResolved(DiscoveredService service) {
    if (service.attributes['server'] != 'boorusama-hub') return;
    if (service.host.isEmpty) return;

    final currentHubs = List<DiscoveredService>.from(state.discoveredHubs);
    if (!currentHubs.any((h) => h.name == service.name)) {
      currentHubs.add(service);
    }

    state = state.copyWith(
      status: SyncDiscoveryStatus.hubFound,
      discoveredHubs: currentHubs,
    );
  }

  void _handleServiceLost(DiscoveredService service) {
    final currentHubs = List<DiscoveredService>.from(state.discoveredHubs);
    currentHubs.removeWhere((h) => h.name == service.name);

    state = state.copyWith(
      discoveredHubs: currentHubs,
      status: currentHubs.isEmpty
          ? SyncDiscoveryStatus.noHubFound
          : SyncDiscoveryStatus.hubFound,
    );
  }

  Future<void> stopDiscovery() async {
    _discoveryTimer?.cancel();
    _discoveryTimer = null;
    await _discoveryClient?.stopDiscovery();
    _discoveryClient = null;
  }

  void reset() {
    stopDiscovery();
    state = const SyncDiscoveryState.initial();
  }
}

final syncDiscoveryProvider =
    NotifierProvider<SyncDiscoveryNotifier, SyncDiscoveryState>(
      SyncDiscoveryNotifier.new,
    );
