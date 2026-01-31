import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;

import 'package:boorusama/core/backups/sync/hub/sync_hub_server.dart';
import 'package:boorusama/core/backups/sync/hub/sync_hub_service.dart';
import 'package:boorusama/core/backups/sync/hub/types.dart';
import 'package:boorusama/core/backups/types/backup_data_source.dart';
import 'package:boorusama/core/backups/types/backup_registry.dart';

void main() {
  group('Sync E2E', () {
    late SyncHubServer server;
    late SyncHubService service;
    late BackupRegistry registry;
    late String serverUrl;
    late Dio dio;
    late SyncHubState state;

    setUp(() async {
      registry = BackupRegistry();
      registry.register(
        _MockBackupSource(
          id: 'bookmarks',
          testData: [
            {'id': 'bm1', 'name': 'Bookmark 1'},
            {'id': 'bm2', 'name': 'Bookmark 2'},
          ],
        ),
      );
      registry.register(
        _MockBackupSource(
          id: 'tags',
          testData: [
            {'id': 't1', 'name': 'tag1'},
            {'id': 't2', 'name': 'tag2'},
          ],
        ),
      );

      service = SyncHubService(registry: registry);
      state = const SyncHubState.initial();

      server = SyncHubServer(
        stateGetter: () => state,
        onConnect: (req) async {
          final clientId = req.clientId ?? service.generateClientId();
          state = service.handleConnect(state, req);
          return ConnectResponse(clientId: clientId, phase: state.phase);
        },
        onStage: (sourceId, req) async {
          final (newState, count) = service.handleStage(state, sourceId, req);
          state = newState;
          return StageResponse.success(count);
        },
        onExport: (sourceId) => service.exportSource(sourceId),
      );

      serverUrl = await server.start(address: 'localhost', port: 0) ?? '';
      dio = Dio(BaseOptions(baseUrl: serverUrl));
    });

    tearDown(() async {
      await server.stop();
      dio.close();
    });

    test('single client full flow', () async {
      // Connect
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      expect(connectRes.data['clientId'], isNotEmpty);
      final clientId = connectRes.data['clientId'];

      // Stage
      final stageRes = await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': '1', 'name': 'Test'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      expect(stageRes.data['stagedCount'], 1);

      // Not confirmed yet
      var status = await dio.get('/sync/status');
      expect(status.data['canPull'], false);

      // Start review and confirm
      state = state.copyWith(
        phase: SyncHubPhase.reviewing,
        conflicts: service.detectConflicts(state),
      );
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      // Now can pull
      status = await dio.get('/sync/status');
      expect(status.data['canPull'], true);

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 1);
    });

    test('two clients with no conflicts merge data', () async {
      // Client A connects and stages
      final connectA = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectA.data['clientId'],
          'data': [
            {'id': 'a1', 'name': 'From A'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Client B connects and stages different data
      final connectB = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device B'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectB.data['clientId'],
          'data': [
            {'id': 'b1', 'name': 'From B'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Review - no conflicts
      final conflicts = service.detectConflicts(state);
      expect(conflicts, isEmpty);

      // Confirm
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      // Pull merged data
      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 2);
    });

    test('two clients with conflict - keepLocal', () async {
      final connectA = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectA.data['clientId'],
          'data': [
            {'id': 'shared', 'name': 'Version A'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      final connectB = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device B'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectB.data['clientId'],
          'data': [
            {'id': 'shared', 'name': 'Version B'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Detect conflict
      final conflicts = service.detectConflicts(state);
      expect(conflicts.length, 1);
      expect(conflicts[0].uniqueId, 'shared');

      // Resolve keepLocal
      state = state.copyWith(
        phase: SyncHubPhase.reviewing,
        conflicts: [
          conflicts[0].copyWith(resolution: ConflictResolution.keepLocal),
        ],
      );
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 1);
      expect(pullRes.data['data'][0]['name'], 'Version A');
    });

    test('two clients with conflict - keepRemote', () async {
      final connectA = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectA.data['clientId'],
          'data': [
            {'id': 'shared', 'name': 'Version A'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      final connectB = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device B'}),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': connectB.data['clientId'],
          'data': [
            {'id': 'shared', 'name': 'Version B'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      final conflicts = service.detectConflicts(state);
      state = state.copyWith(
        phase: SyncHubPhase.reviewing,
        conflicts: [
          conflicts[0].copyWith(resolution: ConflictResolution.keepRemote),
        ],
      );
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'][0]['name'], 'Version B');
    });

    test('cannot stage after confirmation', () async {
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': '1'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final response = await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': '2'},
          ],
        }),
        options: Options(
          contentType: 'application/json',
          validateStatus: (_) => true,
        ),
      );
      expect(response.statusCode, 400);
    });

    test('cannot pull before confirmation', () async {
      final response = await dio.get(
        '/pull/bookmarks',
        options: Options(validateStatus: (_) => true),
      );
      expect(response.statusCode, 400);
    });

    test('health endpoint returns 204', () async {
      final response = await dio.get('/health');
      expect(response.statusCode, 204);
    });
  });
}

class _MockBackupSource implements BackupDataSource {
  _MockBackupSource({required this.id, required this.testData});

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
      export: _export,
      prepareImport: (_, _) => throw UnimplementedError(),
    ),
    sync: SyncCapability(
      getUniqueIdFromJson: (json) => json['id']?.toString() ?? '',
      importResolved: (_) async {},
    ),
  );

  Future<shelf.Response> _export(shelf.Request request) async {
    return shelf.Response.ok(
      jsonEncode({'version': 1, 'data': testData}),
      headers: {'Content-Type': 'application/json'},
    );
  }

  @override
  Widget buildTile(BuildContext context) => const SizedBox();
}
