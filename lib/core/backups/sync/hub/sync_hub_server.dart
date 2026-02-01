// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// Project imports:
import '../sync_dto.dart';
import 'types.dart';

class ConnectRequest {
  const ConnectRequest({
    required this.clientId,
    required this.deviceName,
  });

  final String? clientId;
  final String deviceName;
}

class ConnectResponse {
  const ConnectResponse({
    required this.clientId,
    required this.phase,
  });

  final String clientId;
  final SyncHubPhase phase;
}

class StageBeginRequest {
  const StageBeginRequest({
    required this.clientId,
    required this.expectedSources,
  });

  final String? clientId;
  final List<String> expectedSources;
}

class StageRequest {
  const StageRequest({
    required this.clientId,
    required this.data,
  });

  final String? clientId;
  final List<Map<String, dynamic>> data;
}

class StageCompleteRequest {
  const StageCompleteRequest({required this.clientId});

  final String? clientId;
}

class StageCompleteResponse {
  const StageCompleteResponse.success(this.sourcesStaged) : error = null;
  const StageCompleteResponse.failure(this.error) : sourcesStaged = 0;

  final int sourcesStaged;
  final String? error;

  bool get isSuccess => error == null;
}

class PullCompleteRequest {
  const PullCompleteRequest({required this.clientId});

  final String? clientId;
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

/// Message types sent from hub to client via WebSocket
enum HubMessageType {
  connected,
  syncConfirmed,
  syncReset,
  error,
}

typedef StateGetter = SyncHubState Function();

class SyncHubServer {
  SyncHubServer({
    required this.stateGetter,
    required this.onConnect,
    required this.onDisconnect,
    required this.onStageBegin,
    required this.onStage,
    required this.onStageComplete,
    required this.onPullComplete,
    required this.onExport,
  });

  final StateGetter stateGetter;
  final Future<ConnectResponse> Function(ConnectRequest request) onConnect;
  final Future<void> Function(String clientId) onDisconnect;
  final Future<void> Function(StageBeginRequest request) onStageBegin;
  final Future<StageResponse> Function(String sourceId, StageRequest request)
  onStage;
  final Future<StageCompleteResponse> Function(StageCompleteRequest request)
  onStageComplete;
  final Future<void> Function(PullCompleteRequest request) onPullComplete;
  final Future<ExportResponse> Function(String sourceId) onExport;

  HttpServer? _server;
  BonsoirBroadcast? _broadcast;

  // Track active WebSocket connections: clientId -> channel
  final Map<String, WebSocketChannel> _clients = {};

  String? get serverUrl => _server != null
      ? 'http://${_server!.address.host}:${_server!.port}'
      : null;

  Future<String?> start({
    required String address,
    required int port,
  }) async {
    final wsHandler = webSocketHandler(_handleWebSocket);

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler((request) {
          // Route WebSocket upgrade requests to wsHandler
          if (request.url.path == 'ws') {
            return wsHandler(request);
          }
          return _handleRequest(request);
        });

    _server = await serve(handler, address, port).timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('Server start timeout'),
    );

    return serverUrl;
  }

  Future<void> stop() async {
    // Close all WebSocket connections - copy list to avoid concurrent modification
    final channels = _clients.values.toList();
    _clients.clear();
    for (final channel in channels) {
      await channel.sink.close();
    }

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

  /// Send a message to a specific client
  void sendToClient(String clientId, HubMessageType type, [Object? data]) {
    final channel = _clients[clientId];
    if (channel == null) return;

    final message = jsonEncode({
      'type': type.name,
      if (data != null) 'data': data,
    });
    channel.sink.add(message);
  }

  /// Broadcast a message to all connected clients
  void broadcast(HubMessageType type, [Object? data]) {
    final message = jsonEncode({
      'type': type.name,
      if (data != null) 'data': data,
    });
    for (final channel in _clients.values) {
      channel.sink.add(message);
    }
  }

  /// Notify all clients that sync has been confirmed and they can pull
  void notifySyncConfirmed() {
    broadcast(HubMessageType.syncConfirmed);
  }

  /// Notify all clients that sync has been reset
  void notifySyncReset() {
    broadcast(HubMessageType.syncReset);
  }

  void _handleWebSocket(WebSocketChannel channel, String? protocol) {
    String? clientId;

    channel.stream.listen(
      (message) async {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final action = json['action'] as String?;

          switch (action) {
            case 'connect':
              final deviceName = json['deviceName'] as String? ?? 'Unknown';
              final existingId = json['clientId'] as String?;

              final request = ConnectRequest(
                clientId: existingId,
                deviceName: deviceName,
              );

              final response = await onConnect(request);
              clientId = response.clientId;

              // Track this connection
              _clients[clientId!] = channel;

              // Send connected confirmation
              channel.sink.add(
                jsonEncode({
                  'type': HubMessageType.connected.name,
                  'data': {
                    'clientId': clientId,
                    'phase': response.phase.name,
                  },
                }),
              );

            default:
              channel.sink.add(
                jsonEncode({
                  'type': HubMessageType.error.name,
                  'data': {'message': 'Unknown action: $action'},
                }),
              );
          }
        } catch (e) {
          channel.sink.add(
            jsonEncode({
              'type': HubMessageType.error.name,
              'data': {'message': e.toString()},
            }),
          );
        }
      },
      onDone: () async {
        // Client disconnected
        if (clientId != null) {
          _clients.remove(clientId);
          await onDisconnect(clientId!);
        }
      },
      onError: (error) async {
        // Connection error - treat as disconnect
        if (clientId != null) {
          _clients.remove(clientId);
          await onDisconnect(clientId!);
        }
      },
    );
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final method = request.method;

    return switch ((method, path)) {
      ('GET', 'hub/status') => _handleHubStatus(),
      ('GET', 'health') => Response(204),
      ('GET', 'sync/status') => _handleSyncStatus(),
      ('POST', 'stage/begin') => _handleStageBegin(request),
      ('POST', 'stage/complete') => _handleStageComplete(request),
      (_, _) when method == 'POST' && path.startsWith('stage/') => _handleStage(
        request,
        path.substring(6),
      ),
      ('GET', 'pull/all') => _handlePullAll(),
      ('POST', 'pull/complete') => _handlePullComplete(request),
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

  Future<Response> _handleStageBegin(Request request) async {
    final state = stateGetter();
    if (state.phase != SyncHubPhase.waiting) {
      return Response(400, body: 'Sync session in progress, cannot stage');
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = StageBeginRequestDto.fromJson(json);

      if (dto.clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      if (dto.expectedSources.isEmpty) {
        return Response(400, body: 'expectedSources cannot be empty');
      }

      final beginRequest = StageBeginRequest(
        clientId: dto.clientId,
        expectedSources: dto.expectedSources,
      );

      await onStageBegin(beginRequest);

      return _jsonResponse(const StageBeginResponseDto().toJson());
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _handleStageComplete(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = StageCompleteRequestDto.fromJson(json);

      if (dto.clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      final completeRequest = StageCompleteRequest(clientId: dto.clientId);
      final result = await onStageComplete(completeRequest);

      if (result.isSuccess) {
        return _jsonResponse(
          StageCompleteResponseDto(
            sourcesStaged: result.sourcesStaged,
          ).toJson(),
        );
      } else {
        return Response(400, body: result.error);
      }
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Future<Response> _handleStage(Request request, String sourceId) async {
    final state = stateGetter();
    if (state.phase != SyncHubPhase.waiting) {
      return Response(400, body: 'Sync session in progress, cannot stage');
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

  Response _handlePullAll() {
    final state = stateGetter();
    if (state.phase != SyncHubPhase.confirmed) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    final dto = PullAllResponseDto(sources: state.resolvedData);
    return _jsonResponse(dto.toJson());
  }

  Future<Response> _handlePullComplete(Request request) async {
    final state = stateGetter();
    if (state.phase != SyncHubPhase.confirmed &&
        state.phase != SyncHubPhase.completed) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final clientId = json['clientId'] as String?;

      if (clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      await onPullComplete(PullCompleteRequest(clientId: clientId));

      return _jsonResponse({'success': true});
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
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
