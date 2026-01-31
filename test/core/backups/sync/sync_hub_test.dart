import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() {
  group('Sync Hub Integration', () {
    late HttpServer server;
    late String serverUrl;
    late Dio dio;
    late _TestSyncHub hub;

    setUp(() async {
      hub = _TestSyncHub();
      server = await shelf_io.serve(hub.handler, 'localhost', 0);
      serverUrl = 'http://localhost:${server.port}';
      dio = Dio(BaseOptions(baseUrl: serverUrl));
    });

    tearDown(() async {
      await server.close(force: true);
      dio.close();
    });

    test('client can connect to hub and receive clientId', () async {
      final response = await dio.post(
        '/connect',
        data: jsonEncode({
          'clientId': null,
          'deviceName': 'Test Device',
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(response.statusCode, 200);
      expect(response.data['success'], true);
      expect(response.data['clientId'], isNotNull);
      expect(response.data['phase'], 'waiting');
    });

    test('client can stage data to hub', () async {
      // First connect
      final connectResponse = await dio.post(
        '/connect',
        data: jsonEncode({
          'clientId': null,
          'deviceName': 'Test Device',
        }),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectResponse.data['clientId'];

      // Then stage
      final stageResponse = await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': 1, 'name': 'Item 1'},
            {'id': 2, 'name': 'Item 2'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(stageResponse.statusCode, 200);
      expect(stageResponse.data['success'], true);
      expect(stageResponse.data['stagedCount'], 2);

      // Verify staged data
      expect(hub.stagedData['test_source'], isNotNull);
      expect(hub.stagedData['test_source']!.length, 1);
      expect(hub.stagedData['test_source']![0].data.length, 2);
    });

    test('staging without clientId returns 400', () async {
      try {
        await dio.post(
          '/stage/test_source',
          data: jsonEncode({
            'data': [
              {'id': 1},
            ],
          }),
          options: Options(contentType: 'application/json'),
        );
        fail('Expected exception');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 400);
      }
    });

    test('hub detects conflicts between clients', () async {
      // Client 1 connects and stages
      final connect1 = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device 1'}),
        options: Options(contentType: 'application/json'),
      );
      final client1Id = connect1.data['clientId'];

      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': client1Id,
          'data': [
            {'id': '1', 'name': 'Item A', 'value': 100},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Client 2 connects and stages conflicting data
      final connect2 = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device 2'}),
        options: Options(contentType: 'application/json'),
      );
      final client2Id = connect2.data['clientId'];

      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': client2Id,
          'data': [
            {
              'id': '1',
              'name': 'Item A',
              'value': 200,
            }, // Same id, different value
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Start review
      hub.startReview();

      expect(hub.phase, _SyncPhase.reviewing);
      expect(hub.conflicts.length, 1);
      expect(hub.conflicts[0].uniqueId, '1');
    });

    test('hub can resolve conflicts and confirm sync', () async {
      // Setup: two clients with conflicting data
      final connect1 = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device 1'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': connect1.data['clientId'],
          'data': [
            {'id': '1', 'value': 'local'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      final connect2 = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device 2'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': connect2.data['clientId'],
          'data': [
            {'id': '1', 'value': 'remote'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Start review and resolve
      hub.startReview();
      expect(hub.conflicts.length, 1);

      hub.resolveConflict(0, _ConflictResolution.keepLocal);
      expect(hub.conflicts[0].resolution, _ConflictResolution.keepLocal);

      // Confirm
      hub.confirmSync();
      expect(hub.phase, _SyncPhase.confirmed);

      // Check sync status
      final statusResponse = await dio.get('/sync/status');
      expect(statusResponse.data['canPull'], true);

      // Pull resolved data
      final pullResponse = await dio.get('/pull/test_source');
      expect(pullResponse.statusCode, 200);
      expect(pullResponse.data['data'], isNotNull);
      final pulledData = pullResponse.data['data'] as List;
      expect(pulledData.length, 1);
      expect(pulledData[0]['value'], 'local'); // We chose keepLocal
    });

    test('cannot pull before confirmation', () async {
      try {
        await dio.get('/pull/test_source');
        fail('Expected exception');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 400);
      }
    });

    test('sync status shows correct phase', () async {
      var response = await dio.get('/sync/status');
      expect(response.data['phase'], 'waiting');
      expect(response.data['canPull'], false);

      // Stage some data
      final connect = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': connect.data['clientId'],
          'data': [
            {'id': '1'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      hub.startReview();
      response = await dio.get('/sync/status');
      expect(response.data['phase'], 'reviewing');

      hub.confirmSync();
      response = await dio.get('/sync/status');
      expect(response.data['phase'], 'confirmed');
      expect(response.data['canPull'], true);
    });

    test('health endpoint returns 204', () async {
      final response = await dio.get('/health');
      expect(response.statusCode, 204);
    });

    test('reset clears staged data and conflicts', () async {
      // Stage some data
      final connect = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Device'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/test_source',
        data: jsonEncode({
          'clientId': connect.data['clientId'],
          'data': [
            {'id': '1'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(hub.stagedData.isNotEmpty, true);

      hub.resetSync();

      expect(hub.stagedData.isEmpty, true);
      expect(hub.conflicts.isEmpty, true);
      expect(hub.phase, _SyncPhase.waiting);
    });
  });
}

// Simplified test implementation of sync hub
enum _SyncPhase { waiting, reviewing, resolved, confirmed }

enum _ConflictResolution { pending, keepLocal, keepRemote }

class _StagedSourceData {
  _StagedSourceData({
    required this.sourceId,
    required this.clientId,
    required this.data,
    required this.stagedAt,
  });

  final String sourceId;
  final String clientId;
  final List<Map<String, dynamic>> data;
  final DateTime stagedAt;
}

class _ConnectedClient {
  _ConnectedClient({
    required this.id,
    required this.deviceName,
    required this.connectedAt,
    this.stagedAt,
  });

  final String id;
  final String deviceName;
  final DateTime connectedAt;
  DateTime? stagedAt;

  bool get hasStaged => stagedAt != null;
}

class _ConflictItem {
  _ConflictItem({
    required this.sourceId,
    required this.uniqueId,
    required this.localData,
    required this.remoteData,
    required this.remoteClientId,
    this.resolution = _ConflictResolution.pending,
  });

  final String sourceId;
  final String uniqueId;
  final Map<String, dynamic> localData;
  final Map<String, dynamic> remoteData;
  final String remoteClientId;
  _ConflictResolution resolution;
}

class _TestSyncHub {
  final Map<String, List<_StagedSourceData>> stagedData = {};
  final List<_ConnectedClient> connectedClients = [];
  final List<_ConflictItem> conflicts = [];
  final Map<String, List<Map<String, dynamic>>> resolvedData = {};
  _SyncPhase phase = _SyncPhase.waiting;

  FutureOr<shelf.Response> handler(shelf.Request request) async {
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == 'health') {
      return shelf.Response(204);
    }

    if (method == 'GET' && path == 'sync/status') {
      return shelf.Response.ok(
        jsonEncode({
          'phase': phase.name,
          'canPull': phase == _SyncPhase.confirmed,
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

    final existing = connectedClients.indexWhere((c) => c.id == clientId);
    if (existing < 0) {
      connectedClients.add(
        _ConnectedClient(
          id: clientId,
          deviceName: deviceName,
          connectedAt: DateTime.now(),
        ),
      );
    }

    return shelf.Response.ok(
      jsonEncode({
        'success': true,
        'clientId': clientId,
        'phase': phase.name,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<shelf.Response> _handleStage(
    shelf.Request request,
    String sourceId,
  ) async {
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

    final staged = _StagedSourceData(
      sourceId: sourceId,
      clientId: clientId,
      data: data,
      stagedAt: DateTime.now(),
    );

    stagedData.putIfAbsent(sourceId, () => []);
    stagedData[sourceId]!.removeWhere((s) => s.clientId == clientId);
    stagedData[sourceId]!.add(staged);

    // Update client staged time
    final clientIndex = connectedClients.indexWhere((c) => c.id == clientId);
    if (clientIndex >= 0) {
      connectedClients[clientIndex].stagedAt = DateTime.now();
    }

    return shelf.Response.ok(
      jsonEncode({
        'success': true,
        'stagedCount': data.length,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  shelf.Response _handlePull(String sourceId) {
    if (phase != _SyncPhase.confirmed) {
      return shelf.Response(400, body: 'Sync not confirmed yet');
    }

    final data = resolvedData[sourceId];
    if (data == null) {
      return shelf.Response.notFound('No resolved data for: $sourceId');
    }

    return shelf.Response.ok(
      jsonEncode({'data': data}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void startReview() {
    if (stagedData.isEmpty) return;

    conflicts.clear();

    for (final entry in stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      if (stagedList.length <= 1) continue;

      // Group items by unique id (using 'id' field)
      final itemsByUniqueId = <String, List<(String, Map<String, dynamic>)>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId = item['id']?.toString() ?? '';
          itemsByUniqueId.putIfAbsent(uniqueId, () => []);
          itemsByUniqueId[uniqueId]!.add((staged.clientId, item));
        }
      }

      // Detect conflicts
      for (final mapEntry in itemsByUniqueId.entries) {
        final items = mapEntry.value;
        if (items.length <= 1) continue;

        final first = items.first;
        for (var i = 1; i < items.length; i++) {
          final other = items[i];
          if (!_areItemsEqual(first.$2, other.$2)) {
            conflicts.add(
              _ConflictItem(
                sourceId: sourceId,
                uniqueId: mapEntry.key,
                localData: first.$2,
                remoteData: other.$2,
                remoteClientId: other.$1,
              ),
            );
          }
        }
      }
    }

    phase = _SyncPhase.reviewing;
  }

  bool _areItemsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  void resolveConflict(int index, _ConflictResolution resolution) {
    if (index < 0 || index >= conflicts.length) return;
    conflicts[index].resolution = resolution;

    if (conflicts.every((c) => c.resolution != _ConflictResolution.pending)) {
      phase = _SyncPhase.resolved;
    }
  }

  void confirmSync() {
    resolvedData.clear();

    for (final entry in stagedData.entries) {
      final sourceId = entry.key;
      final stagedList = entry.value;

      final mergedItems = <String, Map<String, dynamic>>{};

      for (final staged in stagedList) {
        for (final item in staged.data) {
          final uniqueId = item['id']?.toString() ?? '';

          final conflict = conflicts.cast<_ConflictItem?>().firstWhere(
            (c) => c?.sourceId == sourceId && c?.uniqueId == uniqueId,
            orElse: () => null,
          );

          if (conflict != null) {
            if (conflict.resolution == _ConflictResolution.keepLocal) {
              mergedItems[uniqueId] = conflict.localData;
            } else if (conflict.resolution == _ConflictResolution.keepRemote) {
              mergedItems[uniqueId] = conflict.remoteData;
            }
          } else {
            mergedItems[uniqueId] = item;
          }
        }
      }

      resolvedData[sourceId] = mergedItems.values.toList();
    }

    phase = _SyncPhase.confirmed;
  }

  void resetSync() {
    stagedData.clear();
    conflicts.clear();
    resolvedData.clear();
    for (final client in connectedClients) {
      client.stagedAt = null;
    }
    phase = _SyncPhase.waiting;
  }

  String _generateClientId() {
    return DateTime.now().millisecondsSinceEpoch.toRadixString(36);
  }
}
