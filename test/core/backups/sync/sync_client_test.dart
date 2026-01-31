import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

void main() {
  group('Sync Client Integration', () {
    late HttpServer server;
    late String serverUrl;
    late Dio dio;
    late _MockHub hub;

    setUp(() async {
      hub = _MockHub();
      server = await shelf_io.serve(hub.handler, 'localhost', 0);
      serverUrl = 'http://localhost:${server.port}';
      dio = Dio(BaseOptions(
        baseUrl: serverUrl,
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));
    });

    tearDown(() async {
      await server.close(force: true);
      dio.close();
    });

    test('full client flow: connect -> stage -> wait -> pull', () async {
      // 1. Connect
      final connectResponse = await dio.post(
        '/connect',
        data: jsonEncode({
          'clientId': null,
          'deviceName': 'Test Client',
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(connectResponse.statusCode, 200);
      final clientId = connectResponse.data['clientId'] as String;
      expect(clientId, isNotEmpty);

      // 2. Stage data for multiple sources
      final sources = ['bookmarks', 'favorite_tags', 'profiles'];
      for (final source in sources) {
        final stageResponse = await dio.post(
          '/stage/$source',
          data: jsonEncode({
            'clientId': clientId,
            'data': [
              {'id': '${source}_1', 'name': 'Test Item 1'},
              {'id': '${source}_2', 'name': 'Test Item 2'},
            ],
          }),
          options: Options(contentType: 'application/json'),
        );

        expect(stageResponse.statusCode, 200);
        expect(stageResponse.data['success'], true);
        expect(stageResponse.data['stagedCount'], 2);
      }

      // Verify all sources were staged
      expect(hub.stagedData.length, 3);
      expect(hub.stagedData['bookmarks']?.length, 1);
      expect(hub.stagedData['favorite_tags']?.length, 1);
      expect(hub.stagedData['profiles']?.length, 1);

      // 3. Check sync status (should not be ready yet)
      var statusResponse = await dio.get('/sync/status');
      expect(statusResponse.data['canPull'], false);

      // 4. Hub confirms (simulating hub owner action)
      hub.confirmSync();

      // 5. Check sync status again
      statusResponse = await dio.get('/sync/status');
      expect(statusResponse.data['canPull'], true);

      // 6. Pull resolved data
      for (final source in sources) {
        final pullResponse = await dio.get('/pull/$source');
        expect(pullResponse.statusCode, 200);
        expect(pullResponse.data['data'], isNotNull);
      }
    });

    test('client staging with export data format', () async {
      // Simulate what JsonBackupSource.serveData returns
      final exportFormat = {
        'version': 1,
        'exportVersion': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'data': [
          {'id': 1, 'name': 'Bookmark 1', 'url': 'https://example.com/1'},
          {'id': 2, 'name': 'Bookmark 2', 'url': 'https://example.com/2'},
        ],
      };

      // Client parses export data
      final parsedData = exportFormat;
      final data = switch (parsedData) {
        {'data': final List data} => data,
        final List data => data,
        _ => <dynamic>[],
      };

      expect(data.length, 2);

      // Connect first
      final connectResponse = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Test'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectResponse.data['clientId'];

      // Stage with parsed data
      final stageResponse = await dio.post(
        '/stage/bookmarks',
        data: jsonEncode({
          'clientId': clientId,
          'data': data,
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(stageResponse.statusCode, 200);
      expect(stageResponse.data['stagedCount'], 2);
    });

    test('polling for confirmation', () async {
      // Connect and stage
      final connectResponse = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Test'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectResponse.data['clientId'];

      await dio.post(
        '/stage/test',
        data: jsonEncode({
          'clientId': clientId,
          'data': [{'id': '1'}],
        }),
        options: Options(contentType: 'application/json'),
      );

      // Poll before confirmation
      var status = await dio.get('/sync/status');
      expect(status.data['canPull'], false);
      expect(status.data['phase'], 'waiting');

      // Simulate hub confirming
      hub.confirmSync();

      // Poll after confirmation
      status = await dio.get('/sync/status');
      expect(status.data['canPull'], true);
      expect(status.data['phase'], 'confirmed');
    });

    test('empty data array is accepted', () async {
      final connectResponse = await dio.post(
        '/connect',
        data: jsonEncode({'clientId': null, 'deviceName': 'Test'}),
        options: Options(contentType: 'application/json'),
      );
      final clientId = connectResponse.data['clientId'];

      final stageResponse = await dio.post(
        '/stage/empty_source',
        data: jsonEncode({
          'clientId': clientId,
          'data': [],
        }),
        options: Options(contentType: 'application/json'),
      );

      expect(stageResponse.statusCode, 200);
      expect(stageResponse.data['stagedCount'], 0);
    });
  });
}

class _MockHub {
  final Map<String, List<_StagedData>> stagedData = {};
  final List<_Client> clients = [];
  final Map<String, List<Map<String, dynamic>>> resolvedData = {};
  bool confirmed = false;

  FutureOr<shelf.Response> handler(shelf.Request request) async {
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == 'health') {
      return shelf.Response(204);
    }

    if (method == 'GET' && path == 'sync/status') {
      return shelf.Response.ok(
        jsonEncode({
          'phase': confirmed ? 'confirmed' : 'waiting',
          'canPull': confirmed,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (method == 'POST' && path == 'connect') {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final clientId =
          json['clientId'] as String? ?? _generateId();
      final deviceName = json['deviceName'] as String? ?? 'Unknown';

      clients.add(_Client(id: clientId, name: deviceName));

      return shelf.Response.ok(
        jsonEncode({
          'success': true,
          'clientId': clientId,
          'phase': 'waiting',
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (method == 'POST' && path.startsWith('stage/')) {
      final sourceId = path.substring(6);
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

      stagedData.putIfAbsent(sourceId, () => []);
      stagedData[sourceId]!.add(_StagedData(
        clientId: clientId,
        data: data,
      ));

      return shelf.Response.ok(
        jsonEncode({
          'success': true,
          'stagedCount': data.length,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    }

    if (method == 'GET' && path.startsWith('pull/')) {
      if (!confirmed) {
        return shelf.Response(400, body: 'Not confirmed');
      }

      final sourceId = path.substring(5);
      final data = resolvedData[sourceId] ??
          stagedData[sourceId]?.expand((s) => s.data).toList() ??
          [];

      return shelf.Response.ok(
        jsonEncode({'data': data}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return shelf.Response.notFound('Not found: $path');
  }

  void confirmSync() {
    confirmed = true;
    // Merge all staged data into resolved
    for (final entry in stagedData.entries) {
      resolvedData[entry.key] = entry.value.expand((s) => s.data).toList();
    }
  }

  String _generateId() => DateTime.now().millisecondsSinceEpoch.toRadixString(36);
}

class _Client {
  _Client({required this.id, required this.name});
  final String id;
  final String name;
}

class _StagedData {
  _StagedData({required this.clientId, required this.data});
  final String clientId;
  final List<Map<String, dynamic>> data;
}
