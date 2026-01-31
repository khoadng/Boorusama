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
          state = service.handleConnect(
            state,
            ConnectRequest(
              clientId: clientId,
              deviceName: req.deviceName,
              clientAddress: req.clientAddress,
            ),
          );
          return ConnectResponse(clientId: clientId, phase: state.phase);
        },
        onStageBegin: (req) async {
          state = service.handleStageBegin(state, req);
        },
        onStage: (sourceId, req) async {
          final (newState, count) = service.handleStage(state, sourceId, req);
          state = newState;
          return StageResponse.success(count);
        },
        onStageComplete: (req) async {
          final (newState, response) = service.handleStageComplete(state, req);
          state = newState;
          return response;
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

    test('single client full flow with staging ack', () async {
      // Connect
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      // Begin staging
      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientId,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Client should be marked as staging
      expect(state.connectedClients[0].isStaging, true);
      expect(state.connectedClients[0].hasStaged, false);

      // Stage data
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': '1', 'name': 'Test'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Still staging (not complete yet)
      expect(state.connectedClients[0].isStaging, true);
      expect(state.connectedClients[0].stagingProgress, '1/1');

      // Complete staging
      final completeRes = await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(contentType: 'application/json'),
      );

      expect(completeRes.data['success'], true);
      expect(completeRes.data['sourcesStaged'], 1);
      expect(state.connectedClients[0].hasStaged, true);
      expect(state.connectedClients[0].isStaging, false);

      // Confirm sync
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 1);
    });

    test('staging complete fails if sources missing', () async {
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      // Begin staging with 2 sources
      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientId,
          'expectedSources': ['bookmarks', 'tags'],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Only stage 1 source
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

      expect(state.connectedClients[0].stagingProgress, '1/2');

      // Try to complete - should fail
      final completeRes = await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(
          contentType: 'application/json',
          validateStatus: (_) => true,
        ),
      );

      expect(completeRes.statusCode, 400);
      expect(state.connectedClients[0].hasStaged, false);
    });

    test('two clients with no conflicts merge data', () async {
      // Client A
      final connectA = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientIdA = connectA.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientIdA,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientIdA,
          'data': [
            {'id': 'a1', 'name': 'From A'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientIdA}),
        options: Options(contentType: 'application/json'),
      );

      // Client B
      final connectB = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device B'}),
        options: Options(contentType: 'application/json'),
      );
      final clientIdB = connectB.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientIdB,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientIdB,
          'data': [
            {'id': 'b1', 'name': 'From B'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientIdB}),
        options: Options(contentType: 'application/json'),
      );

      // Both should be staged
      expect(state.totalStagedClients, 2);

      // No conflicts
      final conflicts = service.detectConflicts(state);
      expect(conflicts, isEmpty);

      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 2);
    });

    test('pull all returns all sources in single response', () async {
      // Connect and stage
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientId,
          'expectedSources': ['bookmarks', 'tags'],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': 'b1', 'name': 'Bookmark 1'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/tags',
        data: jsonEncode({
          'clientId': clientId,
          'data': [
            {'id': 't1', 'name': 'Tag 1'},
            {'id': 't2', 'name': 'Tag 2'},
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(contentType: 'application/json'),
      );

      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      // Pull all sources at once
      final pullAllRes = await dio.get('/pull/all');
      expect(pullAllRes.statusCode, 200);

      final sources = pullAllRes.data['sources'] as Map<String, dynamic>;
      expect(sources['bookmarks'], hasLength(1));
      expect(sources['tags'], hasLength(2));
    });

    test('two clients with conflict - keepLocal', () async {
      // Setup two clients with conflicting data
      for (final (name, value) in [
        ('Device A', 'Version A'),
        ('Device B', 'Version B'),
      ]) {
        final conn = await dio.post(
          '/connect',
          data: jsonEncode({'deviceName': name}),
          options: Options(contentType: 'application/json'),
        );
        final clientId = conn.data['clientId'];

        await dio.post(
          '/stage/begin',
          data: jsonEncode({
            'clientId': clientId,
            'expectedSources': ['bookmarks'],
          }),
          options: Options(contentType: 'application/json'),
        );
        await dio.post(
          '/stage/bookmarks',
          data: jsonEncode({
            'clientId': clientId,
            'data': [
              {'id': 'shared', 'name': value},
            ],
          }),
          options: Options(contentType: 'application/json'),
        );
        await dio.post(
          '/stage/complete',
          data: jsonEncode({'clientId': clientId}),
          options: Options(contentType: 'application/json'),
        );
      }

      final conflicts = service.detectConflicts(state);
      expect(conflicts.length, 1);

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
      expect(pullRes.data['data'][0]['name'], 'Version A');
    });

    test('conflicts auto-resolve when timestamps differ', () async {
      // Re-register source with timestamp support
      registry = BackupRegistry();
      registry.register(
        _MockBackupSource(
          id: 'bookmarks',
          testData: [],
          hasTimestamps: true,
        ),
      );
      service = SyncHubService(registry: registry);
      state = const SyncHubState.initial();

      // Device A with older timestamp
      final connectA = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientIdA = connectA.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientIdA,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientIdA,
          'data': [
            {
              'id': 'shared',
              'name': 'Old Version',
              'updatedAt': '2024-01-01T00:00:00Z',
            },
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientIdA}),
        options: Options(contentType: 'application/json'),
      );

      // Device B with newer timestamp
      final connectB = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device B'}),
        options: Options(contentType: 'application/json'),
      );
      final clientIdB = connectB.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientIdB,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientIdB,
          'data': [
            {
              'id': 'shared',
              'name': 'New Version',
              'updatedAt': '2024-06-01T00:00:00Z',
            },
          ],
        }),
        options: Options(contentType: 'application/json'),
      );
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientIdB}),
        options: Options(contentType: 'application/json'),
      );

      // No conflicts - auto-resolved by timestamp
      final conflicts = service.detectConflicts(state);
      expect(conflicts, isEmpty);

      // Merge picks the newer version
      state = state.copyWith(
        phase: SyncHubPhase.confirmed,
        resolvedData: service.mergeData(state),
      );

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'][0]['name'], 'New Version');
    });

    test('cannot stage after confirmation', () async {
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      state = state.copyWith(phase: SyncHubPhase.confirmed);

      final response = await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientId,
          'expectedSources': ['bookmarks'],
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

    test('reset clears staging state', () async {
      final connectRes = await dio.post(
        '/connect',
        data: jsonEncode({'deviceName': 'Device A'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectRes.data['clientId'];

      await dio.post(
        '/stage/begin',
        data: jsonEncode({
          'clientId': clientId,
          'expectedSources': ['bookmarks'],
        }),
        options: Options(contentType: 'application/json'),
      );
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
      await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(contentType: 'application/json'),
      );

      expect(state.connectedClients[0].hasStaged, true);

      state = state.onReset();

      expect(state.connectedClients[0].hasStaged, false);
      expect(state.connectedClients[0].expectedSources, isEmpty);
      expect(state.connectedClients[0].stagedSources, isEmpty);
    });
  });
}

class _MockBackupSource implements BackupDataSource {
  _MockBackupSource({
    required this.id,
    required this.testData,
    this.hasTimestamps = false,
  });

  @override
  final String id;
  final List<Map<String, dynamic>> testData;
  final bool hasTimestamps;

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
      getTimestampFromJson: hasTimestamps
          ? (json) {
              final ts = json['updatedAt'] as String?;
              return ts != null ? DateTime.tryParse(ts) : null;
            }
          : null,
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
