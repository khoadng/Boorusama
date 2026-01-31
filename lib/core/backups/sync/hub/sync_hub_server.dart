// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Project imports:
import '../sync_dto.dart';
import '../types.dart';

class ConnectRequest {
  const ConnectRequest({
    required this.clientId,
    required this.deviceName,
    required this.clientAddress,
  });

  final String? clientId;
  final String deviceName;
  final String clientAddress;
}

class ConnectResponse {
  const ConnectResponse({
    required this.clientId,
    required this.phase,
  });

  final String clientId;
  final SyncHubPhase phase;
}

class StageRequest {
  const StageRequest({
    required this.clientId,
    required this.data,
  });

  final String? clientId;
  final List<Map<String, dynamic>> data;
}

class StageResponse {
  const StageResponse.success(this.stagedCount) : error = null;
  const StageResponse.failure(this.error) : stagedCount = 0;

  final int stagedCount;
  final String? error;

  bool get isSuccess => error == null;
}

class ExportResponse {
  const ExportResponse.success(this.data) : error = null;
  const ExportResponse.notFound(this.error) : data = null;

  final String? data;
  final String? error;

  bool get isSuccess => error == null;
}

typedef StateGetter = SyncHubState Function();

class SyncHubServer {
  SyncHubServer({
    required this.stateGetter,
    required this.onConnect,
    required this.onStage,
    required this.onExport,
  });

  final StateGetter stateGetter;
  final Future<ConnectResponse> Function(ConnectRequest request) onConnect;
  final Future<StageResponse> Function(String sourceId, StageRequest request)
  onStage;
  final Future<ExportResponse> Function(String sourceId) onExport;

  HttpServer? _server;
  BonsoirBroadcast? _broadcast;

  String? get serverUrl => _server != null
      ? 'http://${_server!.address.host}:${_server!.port}'
      : null;

  Future<String?> start({
    required String address,
    required int port,
  }) async {
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler(_handleRequest);

    _server = await serve(handler, address, port).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Server start timeout'),
    );

    return serverUrl;
  }

  Future<void> stop() async {
    await _broadcast?.stop();
    await _server?.close(force: true);
    _broadcast = null;
    _server = null;
  }

  Future<void> startBroadcast({
    required String deviceName,
    required String appVersion,
  }) async {
    final server = _server;
    if (server == null) return;

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
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final method = request.method;

    return switch ((method, path)) {
      ('GET', 'hub/status') => _handleHubStatus(),
      ('GET', 'health') => Response(204),
      ('POST', 'connect') => _handleConnect(request),
      ('GET', 'sync/status') => _handleSyncStatus(),
      (_, _) when method == 'POST' && path.startsWith('stage/') => _handleStage(
        request,
        path.substring(6),
      ),
      (_, _) when method == 'GET' && path.startsWith('pull/') => _handlePull(
        path.substring(5),
      ),
      ('GET', _) => _handleExport(path),
      _ => Response.notFound('Not found: $path'),
    };
  }

  Response _handleHubStatus() {
    final dto = HubStatusDto.fromState(stateGetter());
    return _jsonResponse(dto.toJson());
  }

  Response _handleSyncStatus() {
    final state = stateGetter();
    final dto = SyncStatusDto(
      phase: state.phase.name,
      canPull: state.phase == SyncHubPhase.confirmed,
    );
    return _jsonResponse(dto.toJson());
  }

  Future<Response> _handleConnect(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = ConnectRequestDto.fromJson(json);

      final connectRequest = ConnectRequest(
        clientId: dto.clientId,
        deviceName: dto.deviceName,
        clientAddress:
            request.headers['x-forwarded-for'] ?? request.requestedUri.host,
      );

      final result = await onConnect(connectRequest);

      final responseDto = ConnectResponseDto(
        clientId: result.clientId,
        phase: result.phase.name,
      );
      return _jsonResponse(responseDto.toJson());
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _handleStage(Request request, String sourceId) async {
    final state = stateGetter();
    if (state.phase == SyncHubPhase.confirmed) {
      return Response(400, body: 'Sync already confirmed, cannot stage');
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = StageRequestDto.fromJson(json);

      if (dto.clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      final stageRequest = StageRequest(
        clientId: dto.clientId,
        data: dto.data,
      );

      final result = await onStage(sourceId, stageRequest);

      if (result.isSuccess) {
        final responseDto = StageResponseDto(stagedCount: result.stagedCount);
        return _jsonResponse(responseDto.toJson());
      } else {
        return Response(400, body: result.error);
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Response _handlePull(String sourceId) {
    final state = stateGetter();
    if (state.phase != SyncHubPhase.confirmed) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    final resolvedData = state.resolvedData[sourceId];
    if (resolvedData == null) {
      return Response.notFound('No resolved data for: $sourceId');
    }

    final dto = PullResponseDto(data: resolvedData);
    return _jsonResponse(dto.toJson());
  }

  Future<Response> _handleExport(String sourceId) async {
    final result = await onExport(sourceId);

    if (result.isSuccess) {
      return Response.ok(
        result.data,
        headers: {'Content-Type': 'application/json'},
      );
    } else {
      return Response.notFound(result.error);
    }
  }

  Response _jsonResponse(Object data) => Response.ok(
    jsonEncode(data),
    headers: {'Content-Type': 'application/json'},
  );

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
          headers: {'Access-Control-Allow-Origin': '*'},
        );
      };
    };
  }
}
