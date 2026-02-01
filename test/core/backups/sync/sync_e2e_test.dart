import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:boorusama/core/backups/sync/hub/sync_hub_repo.dart';
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
    late _TestSyncHubRepo repo;

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
      repo = _TestSyncHubRepo();

      server = SyncHubServer(repo: repo);

      serverUrl = await server.start(address: 'localhost', port: 0) ?? '';
      dio = Dio(BaseOptions(baseUrl: serverUrl));
    });

    tearDown(() async {
      await server.stop();
      dio.close();
    });

    /// Helper to connect via WebSocket and return clientId
    Future<String> connectClient(String deviceName) {
      final uri = Uri.parse(serverUrl);
      final wsUrl = 'ws://${uri.host}:${uri.port}/ws';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final completer = Completer<String>();

      channel.stream.listen((message) {
        final json = jsonDecode(message as String) as Map<String, dynamic>;
        if (json['type'] == 'connected') {
          final clientId = json['data']['clientId'] as String;
          completer.complete(clientId);
        }
      });

      channel.sink.add(
        jsonEncode({
          'action': 'connect',
          'deviceName': deviceName,
        }),
      );

      return completer.future.timeout(const Duration(seconds: 5));
    }

    test('client connects via WebSocket and disconnects', () async {
      final uri = Uri.parse(serverUrl);
      final wsUrl = 'ws://${uri.host}:${uri.port}/ws';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final completer = Completer<String>();

      channel.stream.listen((message) {
        final json = jsonDecode(message as String) as Map<String, dynamic>;
        if (json['type'] == 'connected') {
          completer.complete(json['data']['clientId'] as String);
        }
      });

      channel.sink.add(
        jsonEncode({
          'action': 'connect',
          'deviceName': 'Test Device',
        }),
      );

      final clientId = await completer.future.timeout(
        const Duration(seconds: 5),
      );

      expect(clientId, isNotEmpty);
      expect(repo.connectedClients.length, 1);
      expect(repo.connectedClients[0].deviceName, 'Test Device');

      // Close WebSocket - should disconnect
      await channel.sink.close();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(repo.connectedClients, isEmpty);
    });

    test('single client full flow with staging ack', () async {
      final clientId = await connectClient('Device A');

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
      expect(repo.connectedClients[0].isStaging, true);
      expect(repo.connectedClients[0].hasStaged, false);

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
      expect(repo.connectedClients[0].isStaging, true);
      expect(repo.connectedClients[0].stagingProgress, '1/1');

      // Complete staging
      final completeRes = await dio.post(
        '/stage/complete',
        data: jsonEncode({'clientId': clientId}),
        options: Options(contentType: 'application/json'),
      );

      expect(completeRes.data['success'], true);
      expect(completeRes.data['sourcesStaged'], 1);
      expect(repo.connectedClients[0].hasStaged, true);
      expect(repo.connectedClients[0].isStaging, false);

      // Confirm sync
      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 1);
    });

    test('staging complete fails if sources missing', () async {
      final clientId = await connectClient('Device A');

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

      expect(repo.connectedClients[0].stagingProgress, '1/2');

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
      expect(repo.connectedClients[0].hasStaged, false);
    });

    test('two clients with no conflicts merge data', () async {
      // Client A
      final clientIdA = await connectClient('Device A');

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
      final clientIdB = await connectClient('Device B');

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
      final stagedCount = repo.connectedClients
          .where((c) => c.hasStaged)
          .length;
      expect(stagedCount, 2);

      // No conflicts
      final conflicts = service.detectConflicts(repo.toState());
      expect(conflicts, isEmpty);

      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'].length, 2);
    });

    test('pull all returns all sources in single response', () async {
      final clientId = await connectClient('Device A');

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

      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

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
        final clientId = await connectClient(name);

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

      final conflicts = service.detectConflicts(repo.toState());
      expect(conflicts.length, 1);

      repo.setPhase(SyncHubPhase.reviewing);
      repo.setConflicts([
        conflicts[0].copyWith(resolution: ConflictResolution.keepLocal),
      ]);
      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

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

      // Device A with older timestamp
      final clientIdA = await connectClient('Device A');

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
      final clientIdB = await connectClient('Device B');

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
      final conflicts = service.detectConflicts(repo.toState());
      expect(conflicts, isEmpty);

      // Merge picks the newer version
      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

      final pullRes = await dio.get('/pull/bookmarks');
      expect(pullRes.data['data'][0]['name'], 'New Version');
    });

    test('cannot stage during review', () async {
      final clientId = await connectClient('Device A');

      // Simulate review in progress
      repo.setPhase(SyncHubPhase.reviewing);

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
      expect(response.data, contains('Sync session in progress'));
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
      final clientId = await connectClient('Device A');

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

      expect(repo.connectedClients[0].hasStaged, true);

      repo.reset();

      expect(repo.connectedClients[0].hasStaged, false);
      expect(repo.connectedClients[0].expectedSources, isEmpty);
      expect(repo.connectedClients[0].stagedSources, isEmpty);
    });

    test('pull complete tracks which clients have pulled', () async {
      // Two clients stage data
      final clients = <String>[];
      for (final name in ['Device A', 'Device B']) {
        final clientId = await connectClient(name);
        clients.add(clientId);

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
              {'id': name.toLowerCase().replaceAll(' ', '_')},
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

      final stagedCount = repo.connectedClients
          .where((c) => c.hasStaged)
          .length;
      expect(stagedCount, 2);

      // Confirm sync
      repo.setPhase(SyncHubPhase.confirmed);
      repo.setResolvedData(service.mergeData(repo.toState()));

      // No one has pulled yet
      expect(repo.connectedClients.where((c) => c.hasPulled).length, 0);
      expect(repo.phase, SyncHubPhase.confirmed);

      // Client A pulls and notifies
      await dio.get('/pull/all');
      await dio.post(
        '/pull/complete',
        data: jsonEncode({'clientId': clients[0]}),
        options: Options(contentType: 'application/json'),
      );

      expect(repo.connectedClients.where((c) => c.hasPulled).length, 1);
      expect(repo.connectedClients[0].hasPulled, true);
      expect(repo.connectedClients[1].hasPulled, false);
      expect(repo.phase, SyncHubPhase.confirmed); // Not complete yet

      // Client B pulls and notifies
      await dio.get('/pull/all');
      await dio.post(
        '/pull/complete',
        data: jsonEncode({'clientId': clients[1]}),
        options: Options(contentType: 'application/json'),
      );

      expect(repo.connectedClients.where((c) => c.hasPulled).length, 2);
      expect(repo.phase, SyncHubPhase.completed); // Now complete!
    });

    test('hub broadcasts syncConfirmed to connected clients', () async {
      final uri = Uri.parse(serverUrl);
      final wsUrl = 'ws://${uri.host}:${uri.port}/ws';
      final channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      final messages = <String>[];
      final connectedCompleter = Completer<void>();

      channel.stream.listen((message) {
        final json = jsonDecode(message as String) as Map<String, dynamic>;
        messages.add(json['type'] as String);
        if (json['type'] == 'connected') {
          connectedCompleter.complete();
        }
      });

      channel.sink.add(
        jsonEncode({
          'action': 'connect',
          'deviceName': 'Test',
        }),
      );

      await connectedCompleter.future;

      // Trigger sync confirmed broadcast
      server.notifySyncConfirmed();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(messages, contains('syncConfirmed'));

      await channel.sink.close();
    });
  });
}

/// Test implementation of SyncHubRepo
class _TestSyncHubRepo implements SyncHubRepo {
  SyncHubPhase _phase = SyncHubPhase.waiting;
  final List<ConnectedClient> _connectedClients = [];
  final Map<String, List<StagedSourceData>> _stagedData = {};
  List<ConflictItem> _conflicts = [];
  Map<String, List<Map<String, dynamic>>> _resolvedData = {};
  var _clientIdCounter = 0;

  @override
  SyncHubPhase get phase => _phase;

  @override
  List<ConnectedClient> get connectedClients =>
      List.unmodifiable(_connectedClients);

  @override
  ConnectedClient? getClient(String clientId) =>
      _connectedClients.where((c) => c.id == clientId).firstOrNull;

  @override
  Map<String, List<Map<String, dynamic>>> get resolvedData => _resolvedData;

  @override
  List<Map<String, dynamic>>? getResolvedDataForSource(String sourceId) =>
      _resolvedData[sourceId];

  @override
  bool get canStage => _phase == SyncHubPhase.waiting;

  @override
  bool get canPull =>
      _phase == SyncHubPhase.confirmed || _phase == SyncHubPhase.completed;

  @override
  String generateClientId() => 'client_${++_clientIdCounter}';

  @override
  void addClient(String clientId, String deviceName) {
    final existingIndex = _connectedClients.indexWhere((c) => c.id == clientId);

    if (existingIndex >= 0) {
      _connectedClients[existingIndex] = _connectedClients[existingIndex]
          .copyWith(
            deviceName: deviceName,
          );
    } else {
      _connectedClients.add(
        ConnectedClient(
          id: clientId,
          deviceName: deviceName,
          connectedAt: DateTime.now(),
        ),
      );
    }
  }

  @override
  void removeClient(String clientId) {
    // Check if client had staged data
    final hadStagedData = _stagedData.values.any(
      (list) => list.any((s) => s.clientId == clientId),
    );

    // If past waiting phase and client had staged data, reset the sync
    if (_phase != SyncHubPhase.waiting && hadStagedData) {
      _connectedClients.removeWhere((c) => c.id == clientId);
      for (var i = 0; i < _connectedClients.length; i++) {
        _connectedClients[i] = _connectedClients[i].onReset();
      }
      _phase = SyncHubPhase.waiting;
      _stagedData.clear();
      _conflicts.clear();
      _resolvedData.clear();
      return;
    }

    // Otherwise just remove client and their staged data
    _connectedClients.removeWhere((c) => c.id == clientId);
    for (final sourceId in _stagedData.keys.toList()) {
      _stagedData[sourceId]?.removeWhere((s) => s.clientId == clientId);
      if (_stagedData[sourceId]?.isEmpty ?? false) {
        _stagedData.remove(sourceId);
      }
    }
  }

  @override
  void beginStaging(String clientId, List<String> expectedSources) {
    final clientIndex = _connectedClients.indexWhere((c) => c.id == clientId);
    if (clientIndex < 0) return;

    _connectedClients[clientIndex] = _connectedClients[clientIndex]
        .onStagingStarted(expectedSources);
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

    final sourceStaged = List<StagedSourceData>.from(
      _stagedData[sourceId] ?? [],
    );
    sourceStaged.removeWhere((s) => s.clientId == clientId);
    sourceStaged.add(stagedSourceData);
    _stagedData[sourceId] = sourceStaged;

    // Update client's staged sources
    final clientIndex = _connectedClients.indexWhere((c) => c.id == clientId);
    if (clientIndex >= 0) {
      final client = _connectedClients[clientIndex];
      if (!client.stagedSources.contains(sourceId)) {
        _connectedClients[clientIndex] = client.onSourceStaged(sourceId);
      }
    }
  }

  @override
  void completeStaging(String clientId) {
    final clientIndex = _connectedClients.indexWhere((c) => c.id == clientId);
    if (clientIndex < 0) return;

    _connectedClients[clientIndex] = _connectedClients[clientIndex]
        .onStagingComplete();
  }

  @override
  void completePull(String clientId) {
    final clientIndex = _connectedClients.indexWhere((c) => c.id == clientId);
    if (clientIndex < 0) return;

    _connectedClients[clientIndex] = _connectedClients[clientIndex].onPulled();

    // Check if all staged clients have pulled
    final allPulled = _connectedClients
        .where((c) => c.hasStaged)
        .every((c) => c.hasPulled);
    if (allPulled && _connectedClients.any((c) => c.hasStaged)) {
      _phase = SyncHubPhase.completed;
    }
  }

  // Test helpers
  void setPhase(SyncHubPhase phase) => _phase = phase;

  void setResolvedData(Map<String, List<Map<String, dynamic>>> data) =>
      _resolvedData = data;

  void setConflicts(List<ConflictItem> conflicts) => _conflicts = conflicts;

  void reset() {
    _phase = SyncHubPhase.waiting;
    _stagedData.clear();
    _conflicts = [];
    _resolvedData = {};
    for (var i = 0; i < _connectedClients.length; i++) {
      _connectedClients[i] = _connectedClients[i].onReset();
    }
  }

  SyncHubState toState() => SyncHubState(
    isRunning: true,
    serverUrl: null,
    connectedClients: _connectedClients,
    phase: _phase,
    stagedData: _stagedData,
    conflicts: _conflicts,
    resolvedData: _resolvedData,
  );
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
