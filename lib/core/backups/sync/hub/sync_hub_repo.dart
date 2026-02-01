// Project imports:
import 'types.dart';

abstract class SyncHubRepo {
  // Queries
  SyncHubPhase get phase;
  List<ConnectedClient> get connectedClients;
  ConnectedClient? getClient(String clientId);
  Map<String, List<Map<String, dynamic>>> get resolvedData;
  List<Map<String, dynamic>>? getResolvedDataForSource(String sourceId);
  bool get canStage;
  bool get canPull;

  // Commands
  String generateClientId();
  void addClient(String clientId, String deviceName);
  void removeClient(String clientId);
  void beginStaging(String clientId, List<String> expectedSources);
  void stageData(
    String clientId,
    String sourceId,
    List<Map<String, dynamic>> data,
  );
  void completeStaging(String clientId);
  void completePull(String clientId);
}

class SyncHubRepoImpl implements SyncHubRepo {
  SyncHubRepoImpl({
    required SyncHubState Function() getState,
    required void Function(SyncHubState) setState,
    this.onAllClientsPulled,
  }) : _getState = getState,
       _setState = setState;

  final SyncHubState Function() _getState;
  final void Function(SyncHubState) _setState;
  final void Function()? onAllClientsPulled;

  SyncHubState get _state => _getState();

  @override
  SyncHubPhase get phase => _state.phase;

  @override
  List<ConnectedClient> get connectedClients => _state.connectedClients;

  @override
  ConnectedClient? getClient(String clientId) =>
      _state.connectedClients.where((c) => c.id == clientId).firstOrNull;

  @override
  Map<String, List<Map<String, dynamic>>> get resolvedData =>
      _state.resolvedData;

  @override
  List<Map<String, dynamic>>? getResolvedDataForSource(String sourceId) =>
      _state.resolvedData[sourceId];

  @override
  bool get canStage => _state.phase == SyncHubPhase.waiting;

  @override
  bool get canPull =>
      _state.phase == SyncHubPhase.confirmed ||
      _state.phase == SyncHubPhase.completed;

  @override
  String generateClientId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  @override
  void addClient(String clientId, String deviceName) {
    final existingIndex = _state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (existingIndex >= 0) {
      final updated = List<ConnectedClient>.from(_state.connectedClients);
      updated[existingIndex] = updated[existingIndex].copyWith(
        deviceName: deviceName,
      );
      _setState(_state.copyWith(connectedClients: updated));
    } else {
      _setState(
        _state.copyWith(
          connectedClients: [
            ..._state.connectedClients,
            ConnectedClient(
              id: clientId,
              deviceName: deviceName,
              connectedAt: DateTime.now(),
            ),
          ],
        ),
      );
    }
  }

  @override
  void removeClient(String clientId) {
    // Remove client's staged data
    final cleanedStagedData = <String, List<StagedSourceData>>{};
    for (final entry in _state.stagedData.entries) {
      final filtered = entry.value
          .where((s) => s.clientId != clientId)
          .toList();
      if (filtered.isNotEmpty) {
        cleanedStagedData[entry.key] = filtered;
      }
    }

    _setState(
      _state.copyWith(
        connectedClients: _state.connectedClients
            .where((c) => c.id != clientId)
            .toList(),
        stagedData: cleanedStagedData,
      ),
    );
  }

  @override
  void beginStaging(String clientId, List<String> expectedSources) {
    final clientIndex = _state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (clientIndex < 0) return;

    final updated = List<ConnectedClient>.from(_state.connectedClients);
    updated[clientIndex] = updated[clientIndex].onStagingStarted(
      expectedSources,
    );

    _setState(_state.copyWith(connectedClients: updated));
  }

  @override
  void stageData(
    String clientId,
    String sourceId,
    List<Map<String, dynamic>> data,
  ) {
    final stagedSourceData = StagedSourceData(
      sourceId: sourceId,
      clientId: clientId,
      data: data,
      stagedAt: DateTime.now(),
    );

    final currentStaged = Map<String, List<StagedSourceData>>.from(
      _state.stagedData,
    );
    final sourceStaged = List<StagedSourceData>.from(
      currentStaged[sourceId] ?? [],
    );

    sourceStaged.removeWhere((s) => s.clientId == clientId);
    sourceStaged.add(stagedSourceData);
    currentStaged[sourceId] = sourceStaged;

    final clientIndex = _state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );
    List<ConnectedClient>? updatedClients;
    if (clientIndex >= 0) {
      final client = _state.connectedClients[clientIndex];
      if (!client.stagedSources.contains(sourceId)) {
        updatedClients = List<ConnectedClient>.from(_state.connectedClients);
        updatedClients[clientIndex] = client.onSourceStaged(sourceId);
      }
    }

    _setState(
      _state.copyWith(
        stagedData: currentStaged,
        connectedClients: updatedClients,
      ),
    );
  }

  @override
  void completeStaging(String clientId) {
    final clientIndex = _state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (clientIndex < 0) return;

    final updated = List<ConnectedClient>.from(_state.connectedClients);
    updated[clientIndex] = updated[clientIndex].onStagingComplete();

    _setState(_state.copyWith(connectedClients: updated));
  }

  @override
  void completePull(String clientId) {
    final clientIndex = _state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (clientIndex < 0) return;

    final updated = List<ConnectedClient>.from(_state.connectedClients);
    updated[clientIndex] = updated[clientIndex].onPulled();

    var newState = _state.copyWith(connectedClients: updated);

    if (newState.allStagedClientsPulled) {
      newState = newState.copyWith(phase: SyncHubPhase.completed);
      onAllClientsPulled?.call();
    }

    _setState(newState);
  }
}
