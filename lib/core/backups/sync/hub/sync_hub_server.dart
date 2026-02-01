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

/// Message types sent from hub to client via WebSocket
enum HubMessageType {
  connected,
  syncConfirmed,
  syncReset,
  error,
}

typedef StateGetter = SyncHubState Function();

class SyncHubServer {
  SyncHubServer({required this.stateGetter});

  final StateGetter stateGetter;

  HttpServer? _server;
  BonsoirBroadcast? _broadcast;
  var _isDisposed = false;

  final _eventController = StreamController<SyncHubEvent>.broadcast();
  Stream<SyncHubEvent> get events => _eventController.stream;

  void _emitEvent(SyncHubEvent event) {
    if (_isDisposed) return;
    _eventController.add(event);
  }

  // Track active WebSocket connections: clientId -> channel
  final Map<String, WebSocketChannel> _clients = {};

  String? get serverUrl => _server != null
      ? 'http://${_server!.address.host}:${_server!.port}'
      : null;

  String generateClientId() =>
      DateTime.now().millisecondsSinceEpoch.toRadixString(36);

  Future<String?> start({
    required String address,
    required int port,
  }) async {
    final wsHandler = webSocketHandler(_handleWebSocket);

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_corsMiddleware())
        .addHandler((request) {
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

  void dispose() {
    _isDisposed = true;
    _eventController.close();
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

  void sendToClient(String clientId, HubMessageType type, [Object? data]) {
    final channel = _clients[clientId];
    if (channel == null) return;

    final message = jsonEncode({
      'type': type.name,
      'data': ?data,
    });
    channel.sink.add(message);
  }

  void broadcast(HubMessageType type, [Object? data]) {
    final message = jsonEncode({
      'type': type.name,
      'data': ?data,
    });
    for (final channel in _clients.values) {
      channel.sink.add(message);
    }
  }

  void notifySyncConfirmed() {
    broadcast(HubMessageType.syncConfirmed);
  }

  void notifySyncReset() {
    broadcast(HubMessageType.syncReset);
  }

  void _handleWebSocket(WebSocketChannel channel, String? protocol) {
    String? clientId;

    channel.stream.listen(
      (message) {
        try {
          final json = jsonDecode(message as String) as Map<String, dynamic>;
          final action = json['action'] as String?;

          switch (action) {
            case 'connect':
              final deviceName = json['deviceName'] as String? ?? 'Unknown';
              final existingId = json['clientId'] as String?;

              clientId = existingId ?? generateClientId();
              _clients[clientId!] = channel;

              _emitEvent(
                ClientConnectedEvent(
                  clientId: clientId!,
                  deviceName: deviceName,
                ),
              );

              final state = stateGetter();
              channel.sink.add(
                jsonEncode({
                  'type': HubMessageType.connected.name,
                  'data': {
                    'clientId': clientId,
                    'phase': state.phase.name,
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
      onDone: () {
        if (clientId != null) {
          _clients.remove(clientId);
          _emitEvent(ClientDisconnectedEvent(clientId: clientId!));
        }
      },
      onError: (error) {
        if (clientId != null) {
          _clients.remove(clientId);
          _emitEvent(ClientDisconnectedEvent(clientId: clientId!));
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

      _emitEvent(
        StageBeginEvent(
          clientId: dto.clientId!,
          expectedSources: dto.expectedSources,
        ),
      );

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

      final state = stateGetter();
      final client = state.connectedClients
          .where((c) => c.id == dto.clientId)
          .firstOrNull;

      if (client == null) {
        return Response(400, body: 'Client not found');
      }

      final missingSources = client.expectedSources
          .where((s) => !client.stagedSources.contains(s))
          .toList();

      if (missingSources.isNotEmpty) {
        return Response(
          400,
          body: 'Missing sources: ${missingSources.join(", ")}',
        );
      }

      _emitEvent(StageCompleteEvent(clientId: dto.clientId!));

      return _jsonResponse(
        StageCompleteResponseDto(
          sourcesStaged: client.stagedSources.length,
        ).toJson(),
      );
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

      _emitEvent(
        StageDataEvent(
          clientId: dto.clientId!,
          sourceId: sourceId,
          data: dto.data,
        ),
      );

      final responseDto = StageResponseDto(stagedCount: dto.data.length);
      return _jsonResponse(responseDto.toJson());
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

      _emitEvent(PullCompleteEvent(clientId: clientId));

      return _jsonResponse({'success': true});
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
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
