import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:boorusama/core/backups/sync/hub/types.dart';
import 'package:boorusama/core/backups/sync/merge_strategy.dart';
import 'package:boorusama/core/backups/sync/types.dart';
import 'package:boorusama/core/backups/types/backup_data_source.dart';
import 'package:boorusama/core/backups/types/backup_registry.dart';

void main() {
  group('Sync Hub E2E', () {
    late HttpServer server;
    late String serverUrl;
    late ProviderContainer container;
    late _TestHubNotifier hubNotifier;
    late BackupRegistry registry;

    setUp(() async {
      // Create a test registry with mock sources
      registry = BackupRegistry();
      registry.register(
        _MockBackupSource(
          id: 'bookmarks',
          testData: [
            {'id': 'bm1', 'name': 'Bookmark 1', 'url': 'https://example.com/1'},
            {'id': 'bm2', 'name': 'Bookmark 2', 'url': 'https://example.com/2'},
          ],
        ),
      );
      registry.register(
        _MockBackupSource(
          id: 'favorite_tags',
          testData: [
            {'id': 'ft1', 'name': 'tag1'},
            {'id': 'ft2', 'name': 'tag2'},
          ],
        ),
      );

      // Create hub notifier
      hubNotifier = _TestHubNotifier(registry);

      // Start server
      server = await shelf_io.serve(hubNotifier.handler, 'localhost', 0);
      serverUrl = 'http://localhost:${server.port}';

      container = ProviderContainer();
    });

    tearDown(() async {
      await server.close(force: true);
      container.dispose();
    });

    test('single client full sync flow', () async {
      final client = _TestClient(serverUrl, registry);

      // 1. Connect
      await client.connect('Device A');
      expect(client.clientId, isNotNull);
      expect(hubNotifier.state.connectedClients.length, 1);
      expect(hubNotifier.state.connectedClients[0].deviceName, 'Device A');

      // 2. Stage all sources
      await client.stageAllSources();
      expect(hubNotifier.state.stagedData.length, 2);
      expect(hubNotifier.state.connectedClients[0].hasStaged, true);

      // 3. Start review (no conflicts with single client)
      hubNotifier.startReview();
      expect(hubNotifier.state.phase, SyncHubPhase.reviewing);
      expect(hubNotifier.state.conflicts, isEmpty);

      // 4. Confirm sync
      await hubNotifier.confirmSync();
      expect(hubNotifier.state.phase, SyncHubPhase.confirmed);

      // 5. Client can pull
      final canPull = await client.checkCanPull();
      expect(canPull, true);

      // 6. Pull data
      final pulledData = await client.pullAllSources();
      expect(pulledData['bookmarks']?.length, 2);
      expect(pulledData['favorite_tags']?.length, 2);
    });

    test('two clients with no conflicts', () async {
      final clientA = _TestClient(serverUrl, registry);
      final clientB = _TestClient(serverUrl, registry);

      // Both clients connect
      await clientA.connect('Device A');
      await clientB.connect('Device B');
      expect(hubNotifier.state.connectedClients.length, 2);

      // Client A stages its data
      await clientA.stageData('bookmarks', [
        {'id': 'a1', 'name': 'A Bookmark 1'},
      ]);

      // Client B stages different data (no overlap)
      await clientB.stageData('bookmarks', [
        {'id': 'b1', 'name': 'B Bookmark 1'},
      ]);

      // Review - no conflicts because IDs are different
      hubNotifier.startReview();
      expect(hubNotifier.state.conflicts, isEmpty);

      // Confirm
      await hubNotifier.confirmSync();

      // Both clients pull merged data
      final dataA = await clientA.pullSource('bookmarks');
      final dataB = await clientB.pullSource('bookmarks');

      // Both should have both items
      expect(dataA?.length, 2);
      expect(dataB?.length, 2);
    });

    test('two clients with conflicts - resolve keep local', () async {
      final clientA = _TestClient(serverUrl, registry);
      final clientB = _TestClient(serverUrl, registry);

      await clientA.connect('Device A');
      await clientB.connect('Device B');

      // Both stage data with same ID but different values
      await clientA.stageData('bookmarks', [
        {'id': 'shared', 'name': 'Version A', 'value': 100},
      ]);
      await clientB.stageData('bookmarks', [
        {'id': 'shared', 'name': 'Version B', 'value': 200},
      ]);

      // Review - should detect conflict
      hubNotifier.startReview();
      expect(hubNotifier.state.conflicts.length, 1);
      expect(hubNotifier.state.conflicts[0].uniqueId, 'shared');
      expect(hubNotifier.state.hasUnresolvedConflicts, true);

      // Resolve: keep local (first client's data)
      hubNotifier.resolveConflict(0, ConflictResolution.keepLocal);
      expect(hubNotifier.state.hasUnresolvedConflicts, false);

      // Confirm
      await hubNotifier.confirmSync();

      // Pull and verify
      final data = await clientA.pullSource('bookmarks');
      expect(data?.length, 1);
      expect(data?[0]['name'], 'Version A');
      expect(data?[0]['value'], 100);
    });

    test('two clients with conflicts - resolve keep remote', () async {
      final clientA = _TestClient(serverUrl, registry);
      final clientB = _TestClient(serverUrl, registry);

      await clientA.connect('Device A');
      await clientB.connect('Device B');

      await clientA.stageData('bookmarks', [
        {'id': 'shared', 'name': 'Version A'},
      ]);
      await clientB.stageData('bookmarks', [
        {'id': 'shared', 'name': 'Version B'},
      ]);

      hubNotifier.startReview();
      hubNotifier.resolveConflict(0, ConflictResolution.keepRemote);
      await hubNotifier.confirmSync();

      final data = await clientA.pullSource('bookmarks');
      expect(data?[0]['name'], 'Version B');
    });

    test('resolve all conflicts at once', () async {
      final clientA = _TestClient(serverUrl, registry);
      final clientB = _TestClient(serverUrl, registry);

      await clientA.connect('Device A');
      await clientB.connect('Device B');

      // Create multiple conflicts
      await clientA.stageData('bookmarks', [
        {'id': '1', 'name': 'A1'},
        {'id': '2', 'name': 'A2'},
        {'id': '3', 'name': 'A3'},
      ]);
      await clientB.stageData('bookmarks', [
        {'id': '1', 'name': 'B1'},
        {'id': '2', 'name': 'B2'},
        {'id': '3', 'name': 'B3'},
      ]);

      hubNotifier.startReview();
      expect(hubNotifier.state.conflicts.length, 3);

      // Resolve all at once
      hubNotifier.resolveAllConflicts(ConflictResolution.keepLocal);
      expect(
        hubNotifier.state.conflicts.every(
          (c) => c.resolution == ConflictResolution.keepLocal,
        ),
        true,
      );
      expect(hubNotifier.state.phase, SyncHubPhase.resolved);
    });

    test('reset sync clears everything', () async {
      final client = _TestClient(serverUrl, registry);

      await client.connect('Device A');
      await client.stageAllSources();

      expect(hubNotifier.state.stagedData.isNotEmpty, true);
      expect(hubNotifier.state.connectedClients[0].hasStaged, true);

      hubNotifier.resetSync();

      expect(hubNotifier.state.stagedData.isEmpty, true);
      expect(hubNotifier.state.conflicts.isEmpty, true);
      expect(hubNotifier.state.phase, SyncHubPhase.waiting);
      expect(hubNotifier.state.connectedClients[0].hasStaged, false);
    });

    test('cannot stage after confirmation', () async {
      final client = _TestClient(serverUrl, registry);

      await client.connect('Device A');
      await client.stageData('bookmarks', [
        {'id': '1'},
      ]);

      hubNotifier.startReview();
      await hubNotifier.confirmSync();

      // Try to stage more data
      final response = await client.stageData('bookmarks', [
        {'id': '2'},
      ]);
      expect(response.statusCode, 400);
    });

    test('multiple sources with mixed conflicts', () async {
      final clientA = _TestClient(serverUrl, registry);
      final clientB = _TestClient(serverUrl, registry);

      await clientA.connect('Device A');
      await clientB.connect('Device B');

      // Bookmarks: conflict on id '1'
      await clientA.stageData('bookmarks', [
        {'id': '1', 'name': 'Conflict A'},
        {'id': '2', 'name': 'Only A'},
      ]);
      await clientB.stageData('bookmarks', [
        {'id': '1', 'name': 'Conflict B'},
        {'id': '3', 'name': 'Only B'},
      ]);

      // Favorite tags: no conflict
      await clientA.stageData('favorite_tags', [
        {'id': 'tag_a', 'name': 'Tag A'},
      ]);
      await clientB.stageData('favorite_tags', [
        {'id': 'tag_b', 'name': 'Tag B'},
      ]);

      hubNotifier.startReview();

      // Only one conflict (bookmarks id '1')
      expect(hubNotifier.state.conflicts.length, 1);
      expect(hubNotifier.state.conflicts[0].sourceId, 'bookmarks');

      hubNotifier.resolveConflict(0, ConflictResolution.keepLocal);
      await hubNotifier.confirmSync();

      // Pull and verify
      final bookmarks = await clientA.pullSource('bookmarks');
      final tags = await clientA.pullSource('favorite_tags');

      // Bookmarks: 3 items (conflict resolved to A, plus unique items)
      expect(bookmarks?.length, 3);

      // Tags: 2 items (no conflict, both merged)
      expect(tags?.length, 2);
    });

    test('client polling detects confirmation', () async {
      final client = _TestClient(serverUrl, registry);

      await client.connect('Device A');
      await client.stageAllSources();

      // Not confirmed yet
      expect(await client.checkCanPull(), false);

      hubNotifier.startReview();
      expect(await client.checkCanPull(), false);

      await hubNotifier.confirmSync();
      expect(await client.checkCanPull(), true);
    });
  });
}

// Test implementation of hub notifier (simplified version without Riverpod complexity)
class _TestHubNotifier {
  _TestHubNotifier(this._registry);

  final BackupRegistry _registry;
  final Map<String, List<Map<String, dynamic>>> _resolvedData = {};

  SyncHubState state = const SyncHubState.initial();

  FutureOr<shelf.Response> handler(shelf.Request request) async {
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == 'health') {
      return shelf.Response(204);
    }

    if (method == 'GET' && path == 'sync/status') {
      return shelf.Response.ok(
        jsonEncode({
          'phase': state.phase.name,
          'canPull': state.phase == SyncHubPhase.confirmed,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (method == 'POST' && path == 'connect') {
      return _handleConnect(request);
    }

    if (method == 'POST' && path.startsWith('stage/')) {
      final sourceId = path.substring(6);
      return _handleStage(request, sourceId);
    }

    if (method == 'GET' && path.startsWith('pull/')) {
      final sourceId = path.substring(5);
      return _handlePull(sourceId);
    }

    return shelf.Response.notFound('Not found: $path');
  }

  Future<shelf.Response> _handleConnect(shelf.Request request) async {
    final body = await request.readAsString();
    final json = jsonDecode(body) as Map<String, dynamic>;

    final clientId = json['clientId'] as String? ?? _generateClientId();
    final deviceName = json['deviceName'] as String? ?? 'Unknown';

    final existing = state.connectedClients.indexWhere((c) => c.id == clientId);
    if (existing < 0) {
      state = state.copyWith(
        connectedClients: [
          ...state.connectedClients,
          ConnectedClient(
            id: clientId,
            address: 'test',
            deviceName: deviceName,
            connectedAt: DateTime.now(),
          ),
        ],
      );
    }

    return shelf.Response.ok(
      jsonEncode({
        'success': true,
        'clientId': clientId,
        'phase': state.phase.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<shelf.Response> _handleStage(
    shelf.Request request,
    String sourceId,
  ) async {
    if (state.phase == SyncHubPhase.confirmed) {
      return shelf.Response(400, body: 'Already confirmed');
    }

    final body = await request.readAsString();
    final json = jsonDecode(body);

    final clientId = json['clientId'] as String?;
    if (clientId == null) {
      return shelf.Response(400, body: 'Missing clientId');
    }

    final rawData = switch (json) {
      {'data': final List<dynamic> data} => data,
      _ => <dynamic>[],
    };
    final data = rawData.map((e) => e as Map<String, dynamic>).toList();

    final staged = StagedSourceData(
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
    sourceStaged.add(staged);
    currentStaged[sourceId] = sourceStaged;

    // Update client staged status
    final clientIndex = state.connectedClients.indexWhere(
      (c) => c.id == clientId,
    );
    final updatedClients = List<ConnectedClient>.from(state.connectedClients);
    if (clientIndex >= 0) {
      updatedClients[clientIndex] = updatedClients[clientIndex].copyWith(
        stagedAt: () => DateTime.now(),
      );
    }

    state = state.copyWith(
      stagedData: currentStaged,
      connectedClients: updatedClients,
    );

    return shelf.Response.ok(
      jsonEncode({'success': true, 'stagedCount': data.length}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  shelf.Response _handlePull(String sourceId) {
    if (state.phase != SyncHubPhase.confirmed) {
      return shelf.Response(400, body: 'Not confirmed');
    }

    final data = _resolvedData[sourceId] ?? [];
    return shelf.Response.ok(
      jsonEncode({'data': data}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void startReview() {
    if (state.stagedData.isEmpty) return;

    final conflicts = <ConflictItem>[];

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      if (stagedList.length <= 1) continue;

      final source = _registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;

      final itemsByUniqueId = <Object, List<(String, Map<String, dynamic>)>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId =
              syncCapability?.getUniqueIdFromJson(item) ??
              item['id']?.toString() ??
              '';
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

    state = state.copyWith(
      phase: SyncHubPhase.reviewing,
      conflicts: conflicts,
    );
  }

  bool _areItemsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  void resolveConflict(int index, ConflictResolution resolution) {
    if (index < 0 || index >= state.conflicts.length) return;

    final updated = List<ConflictItem>.from(state.conflicts);
    updated[index] = updated[index].copyWith(resolution: resolution);

    state = state.copyWith(conflicts: updated);

    if (updated.every((c) => c.resolution != ConflictResolution.pending)) {
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
    _resolvedData.clear();

    for (final entry in state.stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      final source = _registry.getSource(sourceId);
      final syncCapability = source?.capabilities.sync;

      final mergedItems = <Object, Map<String, dynamic>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId =
              syncCapability?.getUniqueIdFromJson(item) ??
              item['id']?.toString() ??
              '';

          final conflict = state.conflicts.cast<ConflictItem?>().firstWhere(
            (c) => c?.sourceId == sourceId && c?.uniqueId == uniqueId,
            orElse: () => null,
          );

          if (conflict != null) {
            if (conflict.resolution == ConflictResolution.keepLocal) {
              mergedItems[uniqueId] = conflict.localData;
            } else if (conflict.resolution == ConflictResolution.keepRemote) {
              mergedItems[uniqueId] = conflict.remoteData;
            }
          } else {
            mergedItems[uniqueId] = item;
          }
        }
      }

      _resolvedData[sourceId] = mergedItems.values.toList();
    }

    state = state.copyWith(phase: SyncHubPhase.confirmed);
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

  String _generateClientId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);
}

// Test client that simulates the real client behavior
class _TestClient {
  _TestClient(this.serverUrl, this.registry);

  final String serverUrl;
  final BackupRegistry registry;
  late final Dio dio = Dio(BaseOptions(baseUrl: serverUrl));

  String? clientId;

  Future<void> connect(String deviceName) async {
    final response = await dio.post(
      '/connect',
      data: jsonEncode({
        'clientId': clientId,
        'deviceName': deviceName,
      }),
      options: Options(contentType: 'application/json'),
    );
    clientId = response.data['clientId'] as String?;
  }

  Future<void> stageAllSources() async {
    for (final source in registry.getAllSources()) {
      if (source.capabilities.sync == null) continue;

      final mockRequest = shelf.Request('GET', Uri.parse('http://localhost/'));
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

      await stageData(source.id, data.cast<Map<String, dynamic>>());
    }
  }

  Future<Response> stageData(
    String sourceId,
    List<Map<String, dynamic>> data,
  ) async {
    return dio.post(
      '/stage/$sourceId',
      data: jsonEncode({
        'clientId': clientId,
        'data': data,
      }),
      options: Options(
        contentType: 'application/json',
        validateStatus: (_) => true, // Don't throw on non-2xx
      ),
    );
  }

  Future<bool> checkCanPull() async {
    final response = await dio.get('/sync/status');
    return response.data['canPull'] as bool? ?? false;
  }

  Future<Map<String, List<Map<String, dynamic>>>> pullAllSources() async {
    final result = <String, List<Map<String, dynamic>>>{};

    for (final source in registry.getAllSources()) {
      if (source.capabilities.sync == null) continue;
      final data = await pullSource(source.id);
      if (data != null) {
        result[source.id] = data;
      }
    }

    return result;
  }

  Future<List<Map<String, dynamic>>?> pullSource(String sourceId) async {
    try {
      final response = await dio.get('/pull/$sourceId');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        return data?.cast<Map<String, dynamic>>();
      }
    } catch (_) {}
    return null;
  }
}

// Mock backup source for testing
class _MockBackupSource implements BackupDataSource {
  _MockBackupSource({
    required this.id,
    required this.testData,
  });

  @override
  final String id;

  final List<Map<String, dynamic>> testData;

  @override
  int get priority => 1;

  @override
  String get displayName => id;

  @override
  BackupCapabilities get capabilities => BackupCapabilities(
    server: ServerCapability(
      export: _serveData,
      prepareImport: (_, __) => throw UnimplementedError(),
    ),
    sync: SyncCapability(
      mergeStrategy: _SimpleMergeStrategy(),
      handlePush: (_) => throw UnimplementedError(),
      getUniqueIdFromJson: (json) => json['id']?.toString() ?? '',
      importResolved: (_) async {},
    ),
  );

  Future<shelf.Response> _serveData(shelf.Request request) async {
    final json = jsonEncode({
      'version': 1,
      'data': testData,
    });
    return shelf.Response.ok(
      json,
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Widget buildTile(BuildContext context) => const SizedBox();
}

class _SimpleMergeStrategy extends MergeStrategy<Map<String, dynamic>> {
  @override
  Object getUniqueId(Map<String, dynamic> item) => item['id']?.toString() ?? '';

  @override
  Object getUniqueIdFromJson(Map<String, dynamic> json) =>
      json['id']?.toString() ?? '';

  @override
  DateTime? getTimestamp(Map<String, dynamic> item) => null;
}
