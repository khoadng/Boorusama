// Package imports:
import 'package:equatable/equatable.dart';

/// Events emitted by the sync hub server.
sealed class SyncHubEvent {}

class ClientConnectedEvent extends SyncHubEvent {
  ClientConnectedEvent({
    required this.clientId,
    required this.deviceName,
  });

  final String clientId;
  final String deviceName;
}

class ClientDisconnectedEvent extends SyncHubEvent {
  ClientDisconnectedEvent({required this.clientId});

  final String clientId;
}

class StageBeginEvent extends SyncHubEvent {
  StageBeginEvent({
    required this.clientId,
    required this.expectedSources,
  });

  final String clientId;
  final List<String> expectedSources;
}

class StageDataEvent extends SyncHubEvent {
  StageDataEvent({
    required this.clientId,
    required this.sourceId,
    required this.data,
  });

  final String clientId;
  final String sourceId;
  final List<Map<String, dynamic>> data;
}

class StageCompleteEvent extends SyncHubEvent {
  StageCompleteEvent({required this.clientId});

  final String clientId;
}

class PullCompleteEvent extends SyncHubEvent {
  PullCompleteEvent({required this.clientId});

  final String clientId;
}

class ExportRequestEvent extends SyncHubEvent {
  ExportRequestEvent({required this.sourceId});

  final String sourceId;
}

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

class ConnectedClient extends Equatable {
  const ConnectedClient({
    required this.id,
    required this.deviceName,
    required this.connectedAt,
    this.expectedSources = const [],
    this.stagedSources = const [],
    this.stagingComplete = false,
    this.hasPulled = false,
  });

  final String id;
  final String deviceName;
  final DateTime connectedAt;
  final List<String> expectedSources;
  final List<String> stagedSources;
  final bool stagingComplete;
  final bool hasPulled;

  bool get hasStaged => stagingComplete;

  bool get isStaging => expectedSources.isNotEmpty && !stagingComplete;

  String get stagingProgress => expectedSources.isEmpty
      ? ''
      : '${stagedSources.length}/${expectedSources.length}';

  ConnectedClient copyWith({
    String? id,
    String? deviceName,
    DateTime? connectedAt,
    List<String>? expectedSources,
    List<String>? stagedSources,
    bool? stagingComplete,
    bool? hasPulled,
  }) => ConnectedClient(
    id: id ?? this.id,
    deviceName: deviceName ?? this.deviceName,
    connectedAt: connectedAt ?? this.connectedAt,
    expectedSources: expectedSources ?? this.expectedSources,
    stagedSources: stagedSources ?? this.stagedSources,
    stagingComplete: stagingComplete ?? this.stagingComplete,
    hasPulled: hasPulled ?? this.hasPulled,
  );

  ConnectedClient onPulled() => copyWith(hasPulled: true);

  ConnectedClient onStagingStarted(List<String> sources) => copyWith(
    expectedSources: sources,
    stagedSources: [],
    stagingComplete: false,
  );

  ConnectedClient onSourceStaged(String sourceId) => copyWith(
    stagedSources: [...stagedSources, sourceId],
  );

  ConnectedClient onStagingComplete() => copyWith(
    stagingComplete: true,
  );

  ConnectedClient onReset() => copyWith(
    expectedSources: [],
    stagedSources: [],
    stagingComplete: false,
    hasPulled: false,
  );

  @override
  List<Object?> get props => [
    id,
    deviceName,
    connectedAt,
    expectedSources,
    stagedSources,
    stagingComplete,
    hasPulled,
  ];
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
  completed,
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

  int get totalPulledClients =>
      connectedClients.where((c) => c.hasPulled).length;

  bool get allStagedClientsPulled =>
      totalStagedClients > 0 &&
      connectedClients.where((c) => c.hasStaged).every((c) => c.hasPulled);

  String get pullProgress =>
      totalStagedClients == 0 ? '' : '$totalPulledClients/$totalStagedClients';

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
    connectedClients: connectedClients.map((c) => c.onReset()).toList(),
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
