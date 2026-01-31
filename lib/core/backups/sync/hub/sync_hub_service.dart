// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:shelf/shelf.dart';

// Project imports:
import '../../types/backup_data_source.dart';
import '../../types/backup_registry.dart';
import 'sync_hub_server.dart';
import 'types.dart';

class SyncHubService {
  SyncHubService({required this.registry});

  final BackupRegistry registry;

  String generateClientId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  SyncHubState handleConnect(SyncHubState state, ConnectRequest request) {
    final clientId = request.clientId ?? generateClientId();

    final existingIndex = state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (existingIndex >= 0) {
      final updated = List<ConnectedClient>.from(state.connectedClients);
      updated[existingIndex] = updated[existingIndex].copyWith(
        address: request.clientAddress,
        deviceName: request.deviceName,
      );
      return state.copyWith(connectedClients: updated);
    }

    return state.copyWith(
      connectedClients: [
        ...state.connectedClients,
        ConnectedClient(
          id: clientId,
          address: request.clientAddress,
          deviceName: request.deviceName,
          connectedAt: DateTime.now(),
        ),
      ],
    );
  }

  (SyncHubState, int) handleStage(
    SyncHubState state,
    String sourceId,
    StageRequest request,
  ) {
    final stagedSourceData = StagedSourceData(
      sourceId: sourceId,
      clientId: request.clientId!,
      data: request.data,
      stagedAt: DateTime.now(),
    );

    final currentStaged = Map<String, List<StagedSourceData>>.from(
      state.stagedData,
    );
    final sourceStaged = List<StagedSourceData>.from(
      currentStaged[sourceId] ?? [],
    );

    sourceStaged.removeWhere((s) => s.clientId == request.clientId);
    sourceStaged.add(stagedSourceData);
    currentStaged[sourceId] = sourceStaged;

    final updatedClients = _updateClientStagedAt(
      state.connectedClients,
      request.clientId!,
    );

    return (
      state.copyWith(
        stagedData: currentStaged,
        connectedClients: updatedClients,
      ),
      request.data.length,
    );
  }

  Future<SyncHubState> stageHubOwnData(SyncHubState state) async {
    const hubClientId = '_hub_self_';
    var currentState = state;

    for (final source in registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        final data = await _exportSourceData(source);
        if (data.isEmpty) continue;

        final stagedSourceData = StagedSourceData(
          sourceId: source.id,
          clientId: hubClientId,
          data: data,
          stagedAt: DateTime.now(),
        );

        final currentStaged = Map<String, List<StagedSourceData>>.from(
          currentState.stagedData,
        );
        final sourceStaged = List<StagedSourceData>.from(
          currentStaged[source.id] ?? [],
        );

        sourceStaged.removeWhere((s) => s.clientId == hubClientId);
        sourceStaged.add(stagedSourceData);
        currentStaged[source.id] = sourceStaged;

        currentState = currentState.copyWith(stagedData: currentStaged);
      } catch (_) {
        // Continue with other sources
      }
    }

    return currentState;
  }

  List<ConflictItem> detectConflicts(SyncHubState state) {
    final conflicts = <ConflictItem>[];

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      if (stagedList.length <= 1) continue;

      final source = registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      final itemsByUniqueId = <Object, List<(String, Map<String, dynamic>)>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId = syncCapability.getUniqueIdFromJson(item);
          itemsByUniqueId.putIfAbsent(uniqueId, () => []);
          itemsByUniqueId[uniqueId]!.add((staged.clientId, item));
        }
      }

      for (final mapEntry in itemsByUniqueId.entries) {
        final items = mapEntry.value;
        if (items.length <= 1) continue;

        final first = items.first;
        for (var i = 1; i < items.length; i++) {
          final other = items[i];
          if (!_areItemsEqual(first.$2, other.$2)) {
            conflicts.add(
              ConflictItem(
                sourceId: sourceId,
                uniqueId: mapEntry.key,
                localData: first.$2,
                remoteData: other.$2,
                remoteClientId: other.$1,
                resolution: ConflictResolution.pending,
              ),
            );
          }
        }
      }
    }

    return conflicts;
  }

  Map<String, List<Map<String, dynamic>>> mergeData(SyncHubState state) {
    final resolvedData = <String, List<Map<String, dynamic>>>{};

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      final source = registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      final mergedItems = <Object, Map<String, dynamic>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId = syncCapability.getUniqueIdFromJson(item);

          final existingConflict = state.conflicts
              .where((c) => c.sourceId == sourceId && c.uniqueId == uniqueId)
              .firstOrNull;

          if (existingConflict != null) {
            switch (existingConflict.resolution) {
              case ConflictResolution.keepLocal:
                mergedItems[uniqueId] = existingConflict.localData;
              case ConflictResolution.keepRemote:
                mergedItems[uniqueId] = existingConflict.remoteData;
              case ConflictResolution.pending:
                break;
            }
          } else {
            mergedItems[uniqueId] = item;
          }
        }
      }

      resolvedData[sourceId] = mergedItems.values.toList();
    }

    return resolvedData;
  }

  Future<void> importResolvedData(
    Map<String, List<Map<String, dynamic>>> resolvedData,
  ) async {
    for (final entry in resolvedData.entries) {
      final sourceId = entry.key;
      final items = entry.value;

      if (items.isEmpty) continue;

      final source = registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        await syncCapability.importResolved(items);
      } catch (_) {
        // Continue with other sources
      }
    }
  }

  Future<ExportResponse> exportSource(String sourceId) async {
    final source = registry.getSource(sourceId);
    if (source == null) {
      return ExportResponse.notFound('Source not found: $sourceId');
    }

    try {
      final request = Request('GET', Uri.parse('http://localhost/'));
      final response = await source.capabilities.server.export(request);
      final data = await response.readAsString();
      return ExportResponse.success(data);
    } catch (e) {
      return ExportResponse.notFound('Export failed: $e');
    }
  }

  List<ConnectedClient> _updateClientStagedAt(
    List<ConnectedClient> clients,
    String clientId,
  ) {
    final now = DateTime.now();
    final existingIndex = clients.indexWhere((c) => c.id == clientId);

    if (existingIndex >= 0) {
      final updated = List<ConnectedClient>.from(clients);
      updated[existingIndex] = updated[existingIndex].copyWith(
        stagedAt: () => now,
      );
      return updated;
    }

    return clients;
  }

  Future<List<Map<String, dynamic>>> _exportSourceData(
    BackupDataSource source,
  ) async {
    final request = Request('GET', Uri.parse('http://localhost/'));
    final response = await source.capabilities.server.export(request);
    final exportData = await response.readAsString();
    final parsed = jsonDecode(exportData);

    final data = switch (parsed) {
      {'data': final List data} => data,
      final List data => data,
      _ => <dynamic>[],
    };

    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  bool _areItemsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
