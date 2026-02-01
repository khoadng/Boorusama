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
    this.clientId,
    this.consecutiveFailures = 0,
    this.lastSyncStats,
    this.errorMessage,
  });

  static const maxFailuresBeforeUnreachable = 3;

  final SyncClientStatus status;
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
    String? Function()? clientId,
    int? consecutiveFailures,
    SyncStats? Function()? lastSyncStats,
    String? Function()? errorMessage,
  }) => SyncClientState(
    status: status ?? this.status,
    clientId: clientId != null ? clientId() : this.clientId,
    consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
    lastSyncStats: lastSyncStats != null ? lastSyncStats() : this.lastSyncStats,
    errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
  );

  // State transitions

  SyncClientState startConnecting() =>
      copyWith(status: SyncClientStatus.connecting);

  SyncClientState onConnected(String newClientId) => copyWith(
    status: SyncClientStatus.staging,
    clientId: () => newClientId,
  );

  SyncClientState onStaged() =>
      copyWith(status: SyncClientStatus.waitingForConfirmation);

  SyncClientState startPulling() => copyWith(status: SyncClientStatus.pulling);

  SyncClientState onPullComplete() =>
      copyWith(status: SyncClientStatus.completed);

  SyncClientState onPollSuccess() => switch (status) {
    SyncClientStatus.hubUnreachable => copyWith(
      status: SyncClientStatus.waitingForConfirmation,
      consecutiveFailures: 0,
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
    SyncClientStatus.hubUnreachable => copyWith(
      status: SyncClientStatus.waitingForConfirmation,
      consecutiveFailures: 0,
    ),
    _ => this,
  };

  SyncClientState toIdle() => copyWith(
    status: SyncClientStatus.idle,
    clientId: () => null,
    consecutiveFailures: 0,
    errorMessage: () => null,
  );

  @override
  List<Object?> get props => [
    status,
    clientId,
    consecutiveFailures,
    lastSyncStats,
    errorMessage,
  ];
}
