// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../types.dart';

enum SyncClientStatus {
  idle,
  connecting,
  staging,
  waitingForConfirmation,
  pulling,
  completed,
  error,
  hubUnreachable,
}

class SyncClientState extends Equatable {
  const SyncClientState({
    required this.status,
    required this.savedHubAddress,
    this.currentHubAddress,
    this.clientId,
    this.consecutiveFailures = 0,
    this.lastSyncStats,
    this.errorMessage,
  });

  const SyncClientState.initial()
    : status = SyncClientStatus.idle,
      savedHubAddress = null,
      currentHubAddress = null,
      clientId = null,
      consecutiveFailures = 0,
      lastSyncStats = null,
      errorMessage = null;

  static const maxFailuresBeforeUnreachable = 3;

  final SyncClientStatus status;
  final String? savedHubAddress;
  final String? currentHubAddress;
  final String? clientId;
  final int consecutiveFailures;
  final SyncStats? lastSyncStats;
  final String? errorMessage;

  bool get isBlocked => switch (status) {
    SyncClientStatus.staging ||
    SyncClientStatus.waitingForConfirmation ||
    SyncClientStatus.pulling => true,
    _ => false,
  };

  SyncClientState copyWith({
    SyncClientStatus? status,
    String? Function()? savedHubAddress,
    String? Function()? currentHubAddress,
    String? Function()? clientId,
    int? consecutiveFailures,
    SyncStats? Function()? lastSyncStats,
    String? Function()? errorMessage,
  }) => SyncClientState(
    status: status ?? this.status,
    savedHubAddress: savedHubAddress != null
        ? savedHubAddress()
        : this.savedHubAddress,
    currentHubAddress: currentHubAddress != null
        ? currentHubAddress()
        : this.currentHubAddress,
    clientId: clientId != null ? clientId() : this.clientId,
    consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
    lastSyncStats: lastSyncStats != null ? lastSyncStats() : this.lastSyncStats,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  // State transitions

  SyncClientState startConnecting(String address) => SyncClientState(
    status: SyncClientStatus.connecting,
    savedHubAddress: savedHubAddress,
    currentHubAddress: address,
  );

  SyncClientState onConnected(String newClientId) => copyWith(
    status: SyncClientStatus.staging,
    clientId: () => newClientId,
  );

  SyncClientState onStaged(String hubAddress) => copyWith(
    status: SyncClientStatus.waitingForConfirmation,
    savedHubAddress: () => hubAddress,
  );

  SyncClientState startPulling() => copyWith(status: SyncClientStatus.pulling);

  SyncClientState onPullComplete() =>
      copyWith(status: SyncClientStatus.completed);

  SyncClientState onPollSuccess() => switch (status) {
    SyncClientStatus.hubUnreachable => SyncClientState(
      status: SyncClientStatus.waitingForConfirmation,
      savedHubAddress: savedHubAddress,
      currentHubAddress: currentHubAddress,
      clientId: clientId,
    ),
    _ when consecutiveFailures > 0 => copyWith(consecutiveFailures: 0),
    _ => this,
  };

  SyncClientState onPollFailure() {
    final failures = consecutiveFailures + 1;
    final shouldMarkUnreachable =
        failures >= maxFailuresBeforeUnreachable &&
        status == SyncClientStatus.waitingForConfirmation;

    return shouldMarkUnreachable
        ? copyWith(
            status: SyncClientStatus.hubUnreachable,
            consecutiveFailures: failures,
            errorMessage: () => 'Hub is not responding',
          )
        : copyWith(consecutiveFailures: failures);
  }

  SyncClientState onError(String message) => copyWith(
    status: SyncClientStatus.error,
    errorMessage: () => message,
  );

  SyncClientState onRetry() => switch (status) {
    SyncClientStatus.hubUnreachable => SyncClientState(
      status: SyncClientStatus.waitingForConfirmation,
      savedHubAddress: savedHubAddress,
      currentHubAddress: currentHubAddress,
      clientId: clientId,
    ),
    _ => this,
  };

  SyncClientState toIdle() => SyncClientState(
    status: SyncClientStatus.idle,
    savedHubAddress: savedHubAddress,
  );

  SyncClientState withoutSavedAddress() => copyWith(
    savedHubAddress: () => null,
  );

  @override
  List<Object?> get props => [
    status,
    savedHubAddress,
    currentHubAddress,
    clientId,
    consecutiveFailures,
    lastSyncStats,
    errorMessage,
  ];
}
