// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/networking.dart';
import '../sources/providers.dart';
import '../types/backup_registry.dart';
import 'types.dart';

const _kHubServerName = 'Sync Hub';

final syncHubProvider = NotifierProvider<SyncHubNotifier, SyncHubState>(
  SyncHubNotifier.new,
);

class SyncHubNotifier extends Notifier<SyncHubState> {
  HttpServer? _server;
  BonsoirBroadcast? _broadcast;
  final Map<String, List<Map<String, dynamic>>> _resolvedData = {};

  @override
  SyncHubState build() => const SyncHubState.initial();

  Logger get _logger => ref.read(loggerProvider);
  BackupRegistry get _registry => ref.read(backupRegistryProvider);

  Future<void> startHub({SyncHubConfig? config}) async {
    if (state.isRunning) return;

    final hubConfig = config ?? state.config;
    state = state.copyWith(config: hubConfig);

    try {
      final address = await ref.read(localIPAddressProvider.future);
      if (address == null) {
        _logger.error(_kHubServerName, 'Failed to get local IP address');
        return;
      }

      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_corsMiddleware())
          .addHandler(_handleRequest);

      _server =
          await serve(
            handler,
            address,
            hubConfig.port ?? 0,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Server start timeout'),
          );

      final serverUrl = 'http://${_server!.address.host}:${_server!.port}';
      _logger.info(_kHubServerName, 'Hub running on $serverUrl');

      state = state.copyWith(
        isRunning: true,
        serverUrl: () => serverUrl,
        phase: SyncHubPhase.waiting,
      );

      if (hubConfig.enableDiscovery) {
        await _startBroadcast();
      }
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to start hub: $e');
      state = state.copyWith(isRunning: false);
    }
  }

  Future<void> stopHub() async {
    try {
      await _broadcast?.stop();
      await _server?.close(force: true);

      _broadcast = null;
      _server = null;
      _resolvedData.clear();

      state = const SyncHubState.initial();
      _logger.info(_kHubServerName, 'Hub stopped');
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to stop hub: $e');
    }
  }

  Future<void> _startBroadcast() async {
    final server = _server;
    if (server == null) return;

    try {
      final deviceName = ref.read(deviceInfoProvider).deviceName ?? 'Sync Hub';
      final appVersion = ref.read(packageInfoProvider).version;

      final service = BonsoirService(
        name: '$deviceName (Hub)',
        type: '_boorusama._tcp',
        port: server.port,
        attributes: {
          'server': 'boorusama-hub',
          'version': appVersion,
          'ip': server.address.host,
          'port': server.port.toString(),
        },
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast?.initialize();
      await _broadcast?.start();
    } catch (e) {
      _logger.error(_kHubServerName, 'Failed to start broadcast: $e');
    }
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final method = request.method;

    _logger.info(_kHubServerName, 'Request: $method $path');

    switch ((method, path)) {
      case ('GET', 'hub/status'):
        return _handleHubStatus();
      case ('GET', 'health'):
        return Response(204);
      case ('POST', 'connect'):
        return _handleConnect(request);
      case ('GET', 'sync/status'):
        return _handleSyncStatus();
      case (_, _) when method == 'POST' && path.startsWith('stage/'):
        final sourceId = path.substring(6);
        _logger.info(_kHubServerName, 'Handling stage for source: $sourceId');
        return _handleStage(request, sourceId);
      case (_, _) when method == 'GET' && path.startsWith('pull/'):
        final sourceId = path.substring(5);
        return _handlePull(sourceId);
      case ('GET', _):
        final source = _registry.getSource(path);
        if (source != null) {
          return source.capabilities.server.export(request);
        }
    }

    _logger.info(_kHubServerName, 'Not found: $method $path');
    return Response.notFound('Not found: $path');
  }

  Response _handleHubStatus() {
    final status = {
      'isRunning': state.isRunning,
      'serverUrl': state.serverUrl,
      'phase': state.phase.name,
      'connectedClients': state.connectedClients
          .map(
            (c) => {
              'id': c.id,
              'address': c.address,
              'deviceName': c.deviceName,
              'connectedAt': c.connectedAt.toIso8601String(),
              'stagedAt': c.stagedAt?.toIso8601String(),
              'hasStaged': c.hasStaged,
            },
          )
          .toList(),
      'totalStagedClients': state.totalStagedClients,
      'conflictsCount': state.conflicts.length,
      'hasUnresolvedConflicts': state.hasUnresolvedConflicts,
      'canConfirm': state.canConfirm,
    };

    return Response.ok(
      jsonEncode(status),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<Response> _handleConnect(Request request) async {
    try {
      final body = await request.readAsString();
      _logger.info(_kHubServerName, 'Connect request body: $body');

      final json = jsonDecode(body) as Map<String, dynamic>;

      final clientId = json['clientId'] as String? ?? _generateClientId();
      final deviceName = json['deviceName'] as String? ?? 'Unknown Device';
      final clientAddress =
          request.headers['x-forwarded-for'] ?? request.requestedUri.host;

      _logger.info(
        _kHubServerName,
        'Client connecting: id=$clientId, name=$deviceName, address=$clientAddress',
      );

      final existingIndex = state.connectedClients.indexWhere(
        (c) => c.id == clientId,
      );

      if (existingIndex >= 0) {
        final updated = List<ConnectedClient>.from(state.connectedClients);
        updated[existingIndex] = updated[existingIndex].copyWith(
          address: clientAddress,
          deviceName: deviceName,
        );
        state = state.copyWith(connectedClients: updated);
      } else {
        state = state.copyWith(
          connectedClients: [
            ...state.connectedClients,
            ConnectedClient(
              id: clientId,
              address: clientAddress,
              deviceName: deviceName,
              connectedAt: DateTime.now(),
            ),
          ],
        );
      }

      return Response.ok(
        jsonEncode({
          'success': true,
          'clientId': clientId,
          'phase': state.phase.name,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      _logger.error(_kHubServerName, 'Connect failed: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _handleStage(Request request, String sourceId) async {
    if (state.phase == SyncHubPhase.confirmed) {
      return Response(400, body: 'Sync already confirmed, cannot stage');
    }

    final source = _registry.getSource(sourceId);
    if (source == null) {
      return Response.notFound('Source not found: $sourceId');
    }

    try {
      final body = await request.readAsString();
      _logger.info(
        _kHubServerName,
        'Stage request body length: ${body.length}',
      );

      final json = jsonDecode(body);

      final clientId = json['clientId'] as String?;
      _logger.info(_kHubServerName, 'Stage clientId: $clientId');

      if (clientId == null) {
        _logger.error(_kHubServerName, 'Stage rejected: missing clientId');
        return Response(400, body: 'Missing clientId');
      }

      final rawData = switch (json) {
        {'data': final List<dynamic> data} => data,
        _ => <dynamic>[],
      };

      _logger.info(
        _kHubServerName,
        'Stage raw data count: ${rawData.length}',
      );

      final data = rawData.map((e) => e as Map<String, dynamic>).toList();

      final stagedSourceData = StagedSourceData(
        sourceId: sourceId,
        clientId: clientId,
        data: data,
        stagedAt: DateTime.now(),
      );

      final currentStaged = Map<String, List<StagedSourceData>>.from(
        state.stagedData,
      );
      final sourceStaged = List<StagedSourceData>.from(
        currentStaged[sourceId] ?? [],
      );

      sourceStaged.removeWhere((s) => s.clientId == clientId);
      sourceStaged.add(stagedSourceData);
      currentStaged[sourceId] = sourceStaged;

      // Update both stagedData and connectedClients in a single state change
      final updatedClients = _getUpdatedClientsList(clientId);

      state = state.copyWith(
        stagedData: currentStaged,
        connectedClients: updatedClients,
      );

      _logger.info(
        _kHubServerName,
        'Staged ${data.length} items for $sourceId from client $clientId. '
        'Total staged sources: ${state.stagedData.length}, '
        'Clients with staged data: ${state.connectedClients.where((c) => c.hasStaged).length}',
      );

      return Response.ok(
        jsonEncode({
          'success': true,
          'stagedCount': data.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      _logger.error(_kHubServerName, 'Stage failed for $sourceId: $e');
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Response _handleSyncStatus() {
    return Response.ok(
      jsonEncode({
        'phase': state.phase.name,
        'canPull': state.phase == SyncHubPhase.confirmed,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Response _handlePull(String sourceId) {
    if (state.phase != SyncHubPhase.confirmed) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    final resolvedData = _resolvedData[sourceId];
    if (resolvedData == null) {
      return Response.notFound('No resolved data for: $sourceId');
    }

    return Response.ok(
      jsonEncode({'data': resolvedData}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  List<ConnectedClient> _getUpdatedClientsList(String clientId) {
    final now = DateTime.now();
    final existingIndex = state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );

    if (existingIndex >= 0) {
      final updated = List<ConnectedClient>.from(state.connectedClients);
      updated[existingIndex] = updated[existingIndex].copyWith(
        stagedAt: () => now,
      );
      return updated;
    }

    return state.connectedClients;
  }

  Future<void> startReview() async {
    // First, stage the hub's own data so it's included in the merge
    await _stageHubOwnData();

    if (state.stagedData.isEmpty) return;

    final conflicts = _detectConflicts();

    state = state.copyWith(
      phase: SyncHubPhase.reviewing,
      conflicts: conflicts,
    );
  }

  Future<void> _stageHubOwnData() async {
    const hubClientId = '_hub_self_';

    for (final source in _registry.getAllSources()) {
      final syncCapability = source.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        // Get hub's local data using the export function
        final mockRequest = Request('GET', Uri.parse('http://localhost/'));
        final exportResponse = await source.capabilities.server.export(
          mockRequest,
        );
        final exportData = await exportResponse.readAsString();
        final parsedData = jsonDecode(exportData);

        final data = switch (parsedData) {
          {'data': final List data} => data,
          final List data => data,
          _ => <dynamic>[],
        };

        if (data.isEmpty) continue;

        final hubData = data.map((e) => e as Map<String, dynamic>).toList();

        final stagedSourceData = StagedSourceData(
          sourceId: source.id,
          clientId: hubClientId,
          data: hubData,
          stagedAt: DateTime.now(),
        );

        final currentStaged = Map<String, List<StagedSourceData>>.from(
          state.stagedData,
        );
        final sourceStaged = List<StagedSourceData>.from(
          currentStaged[source.id] ?? [],
        );

        // Remove any previous hub staging for this source
        sourceStaged.removeWhere((s) => s.clientId == hubClientId);
        sourceStaged.add(stagedSourceData);
        currentStaged[source.id] = sourceStaged;

        state = state.copyWith(stagedData: currentStaged);

        _logger.info(
          _kHubServerName,
          'Hub staged ${hubData.length} items for ${source.id}',
        );
      } catch (e) {
        _logger.error(
          _kHubServerName,
          'Failed to stage hub data for ${source.id}: $e',
        );
      }
    }
  }

  List<ConflictItem> _detectConflicts() {
    final conflicts = <ConflictItem>[];

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      if (stagedList.length <= 1) continue;

      final source = _registry.getSource(sourceId);
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

  bool _areItemsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void resolveConflict(int conflictIndex, ConflictResolution resolution) {
    if (conflictIndex < 0 || conflictIndex >= state.conflicts.length) return;

    final updated = List<ConflictItem>.from(state.conflicts);
    updated[conflictIndex] = updated[conflictIndex].copyWith(
      resolution: resolution,
    );

    state = state.copyWith(conflicts: updated);

    if (!state.hasUnresolvedConflicts) {
      state = state.copyWith(phase: SyncHubPhase.resolved);
    }
  }

  void resolveAllConflicts(ConflictResolution resolution) {
    final updated = state.conflicts
        .map((c) => c.copyWith(resolution: resolution))
        .toList();

    state = state.copyWith(
      conflicts: updated,
      phase: SyncHubPhase.resolved,
    );
  }

  Future<void> confirmSync() async {
    if (state.hasUnresolvedConflicts) return;

    _resolvedData.clear();

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      final source = _registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      final mergedItems = <Object, Map<String, dynamic>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId = syncCapability.getUniqueIdFromJson(item);

          final existingConflict = state.conflicts.firstWhere(
            (c) => c.sourceId == sourceId && c.uniqueId == uniqueId,
            orElse: () => ConflictItem(
              sourceId: '',
              uniqueId: Object(),
              localData: {},
              remoteData: {},
              remoteClientId: '',
              resolution: ConflictResolution.pending,
            ),
          );

          if (existingConflict.sourceId.isNotEmpty) {
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

      _resolvedData[sourceId] = mergedItems.values.toList();
    }

    // Import resolved data for the hub itself
    await _importResolvedDataForHub();

    state = state.copyWith(phase: SyncHubPhase.confirmed);

    _logger.info(_kHubServerName, 'Sync confirmed, clients can now pull');
  }

  Future<void> _importResolvedDataForHub() async {
    for (final entry in _resolvedData.entries) {
      final sourceId = entry.key;
      final resolvedItems = entry.value;

      if (resolvedItems.isEmpty) continue;

      final source = _registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;
      if (syncCapability == null) continue;

      try {
        await syncCapability.importResolved(resolvedItems);

        _logger.info(
          _kHubServerName,
          'Hub imported ${resolvedItems.length} items for $sourceId',
        );
      } catch (e) {
        _logger.error(
          _kHubServerName,
          'Hub failed to import $sourceId: $e',
        );
      }
    }
  }

  void resetSync() {
    _resolvedData.clear();

    final resetClients = state.connectedClients
        .map((c) => c.copyWith(stagedAt: () => null))
        .toList();

    state = state.copyWith(
      phase: SyncHubPhase.waiting,
      stagedData: {},
      conflicts: [],
      connectedClients: resetClients,
    );
  }

  String _generateClientId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }

  Middleware _corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok(
            '',
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type',
            },
          );
        }

        final response = await innerHandler(request);
        return response.change(
          headers: {
            'Access-Control-Allow-Origin': '*',
          },
        );
      };
    };
  }
}
