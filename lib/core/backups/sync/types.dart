// Package imports:
import 'package:equatable/equatable.dart';

class SyncHubConfig extends Equatable {
  const SyncHubConfig({
    this.port,
    this.enableDiscovery = true,
  });

  final int? port;
  final bool enableDiscovery;

  SyncHubConfig copyWith({
    int? Function()? port,
    bool? enableDiscovery,
  }) => SyncHubConfig(
    port: port != null ? port() : this.port,
    enableDiscovery: enableDiscovery ?? this.enableDiscovery,
  );

  @override
  List<Object?> get props => [port, enableDiscovery];
}

class SyncStats extends Equatable {
  const SyncStats({
    required this.itemsReceived,
    required this.itemsMerged,
    required this.itemsSkipped,
  });

  const SyncStats.empty()
    : itemsReceived = 0,
      itemsMerged = 0,
      itemsSkipped = 0;

  final int itemsReceived;
  final int itemsMerged;
  final int itemsSkipped;

  SyncStats operator +(SyncStats other) => SyncStats(
    itemsReceived: itemsReceived + other.itemsReceived,
    itemsMerged: itemsMerged + other.itemsMerged,
    itemsSkipped: itemsSkipped + other.itemsSkipped,
  );

  @override
  List<Object?> get props => [itemsReceived, itemsMerged, itemsSkipped];
}

class MergeResult<T> extends Equatable {
  const MergeResult({
    required this.merged,
    required this.stats,
  });

  final List<T> merged;
  final SyncStats stats;

  @override
  List<Object?> get props => [merged, stats];
}

class ConnectedClient extends Equatable {
  const ConnectedClient({
    required this.id,
    required this.address,
    required this.deviceName,
    required this.connectedAt,
    this.stagedAt,
  });

  final String id;
  final String address;
  final String deviceName;
  final DateTime connectedAt;
  final DateTime? stagedAt;

  bool get hasStaged => stagedAt != null;

  ConnectedClient copyWith({
    String? id,
    String? address,
    String? deviceName,
    DateTime? connectedAt,
    DateTime? Function()? stagedAt,
  }) => ConnectedClient(
    id: id ?? this.id,
    address: address ?? this.address,
    deviceName: deviceName ?? this.deviceName,
    connectedAt: connectedAt ?? this.connectedAt,
    stagedAt: stagedAt != null ? stagedAt() : this.stagedAt,
  );

  @override
  List<Object?> get props => [id, address, deviceName, connectedAt, stagedAt];
}

class ConflictItem extends Equatable {
  const ConflictItem({
    required this.sourceId,
    required this.uniqueId,
    required this.localData,
    required this.remoteData,
    required this.remoteClientId,
    required this.resolution,
  });

  final String sourceId;
  final Object uniqueId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final String remoteClientId;
  final ConflictResolution resolution;

  ConflictItem copyWith({
    String? sourceId,
    Object? uniqueId,
    Map<String, dynamic>? localData,
    Map<String, dynamic>? remoteData,
    String? remoteClientId,
    ConflictResolution? resolution,
  }) => ConflictItem(
    sourceId: sourceId ?? this.sourceId,
    uniqueId: uniqueId ?? this.uniqueId,
    localData: localData ?? this.localData,
    remoteData: remoteData ?? this.remoteData,
    remoteClientId: remoteClientId ?? this.remoteClientId,
    resolution: resolution ?? this.resolution,
  );

  @override
  List<Object?> get props => [
    sourceId,
    uniqueId,
    localData,
    remoteData,
    remoteClientId,
    resolution,
  ];
}

enum ConflictResolution {
  pending,
  keepLocal,
  keepRemote,
}

class StagedSourceData extends Equatable {
  const StagedSourceData({
    required this.sourceId,
    required this.clientId,
    required this.data,
    required this.stagedAt,
  });

  final String sourceId;
  final String clientId;
  final List<Map<String, dynamic>> data;
  final DateTime stagedAt;

  @override
  List<Object?> get props => [sourceId, clientId, data, stagedAt];
}

enum SyncHubPhase {
  waiting,
  reviewing,
  resolved,
  confirmed,
}

class SyncHubState extends Equatable {
  const SyncHubState({
    required this.isRunning,
    required this.serverUrl,
    required this.connectedClients,
    required this.phase,
    required this.stagedData,
    required this.conflicts,
    required this.resolvedData,
    this.config = const SyncHubConfig(),
  });

  const SyncHubState.initial()
    : isRunning = false,
      serverUrl = null,
      connectedClients = const [],
      phase = SyncHubPhase.waiting,
      stagedData = const {},
      conflicts = const [],
      resolvedData = const {},
      config = const SyncHubConfig();

  final bool isRunning;
  final String? serverUrl;
  final List<ConnectedClient> connectedClients;
  final SyncHubPhase phase;
  final Map<String, List<StagedSourceData>> stagedData;
  final List<ConflictItem> conflicts;
  final Map<String, List<Map<String, dynamic>>> resolvedData;
  final SyncHubConfig config;

  int get totalStagedClients =>
      connectedClients.where((c) => c.hasStaged).length;

  bool get hasUnresolvedConflicts =>
      conflicts.any((c) => c.resolution == ConflictResolution.pending);

  bool get canConfirm =>
      phase == SyncHubPhase.reviewing && !hasUnresolvedConflicts;

  SyncHubState copyWith({
    bool? isRunning,
    String? Function()? serverUrl,
    List<ConnectedClient>? connectedClients,
    SyncHubPhase? phase,
    Map<String, List<StagedSourceData>>? stagedData,
    List<ConflictItem>? conflicts,
    Map<String, List<Map<String, dynamic>>>? resolvedData,
    SyncHubConfig? config,
  }) => SyncHubState(
    isRunning: isRunning ?? this.isRunning,
    serverUrl: serverUrl != null ? serverUrl() : this.serverUrl,
    connectedClients: connectedClients ?? this.connectedClients,
    phase: phase ?? this.phase,
    stagedData: stagedData ?? this.stagedData,
    conflicts: conflicts ?? this.conflicts,
    resolvedData: resolvedData ?? this.resolvedData,
    config: config ?? this.config,
  );

  // State transitions

  SyncHubState onStarted(String url) => SyncHubState(
    isRunning: true,
    serverUrl: url,
    connectedClients: const [],
    phase: SyncHubPhase.waiting,
    stagedData: const {},
    conflicts: const [],
    resolvedData: const {},
    config: config,
  );

  SyncHubState onReviewStarted(List<ConflictItem> detectedConflicts) =>
      copyWith(
        phase: SyncHubPhase.reviewing,
        conflicts: detectedConflicts,
      );

  SyncHubState onConflictResolved(int index, ConflictResolution resolution) {
    if (index < 0 || index >= conflicts.length) return this;

    final updated = List<ConflictItem>.from(conflicts);
    updated[index] = updated[index].copyWith(resolution: resolution);

    final allResolved = !updated.any(
      (c) => c.resolution == ConflictResolution.pending,
    );

    return copyWith(
      conflicts: updated,
      phase: allResolved ? SyncHubPhase.resolved : null,
    );
  }

  SyncHubState onAllConflictsResolved(ConflictResolution resolution) =>
      copyWith(
        conflicts: conflicts
            .map((c) => c.copyWith(resolution: resolution))
            .toList(),
        phase: SyncHubPhase.resolved,
      );

  SyncHubState onSyncConfirmed(
    Map<String, List<Map<String, dynamic>>> merged,
  ) => copyWith(
    phase: SyncHubPhase.confirmed,
    resolvedData: merged,
  );

  SyncHubState onReset() => copyWith(
    phase: SyncHubPhase.waiting,
    stagedData: {},
    conflicts: [],
    resolvedData: {},
    connectedClients: connectedClients
        .map((c) => c.copyWith(stagedAt: () => null))
        .toList(),
  );

  @override
  List<Object?> get props => [
    isRunning,
    serverUrl,
    connectedClients,
    phase,
    stagedData,
    conflicts,
    resolvedData,
    config,
  ];
}

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
