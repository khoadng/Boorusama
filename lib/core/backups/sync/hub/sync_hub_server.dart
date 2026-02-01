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
import 'sync_hub_repo.dart';
import 'types.dart';

class SyncHubServer {
  SyncHubServer({required this.repo});

  final SyncHubRepo repo;

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

  void _sendWs(WebSocketChannel channel, WsMessage message) {
    channel.sink.add(jsonEncode(message.toJson()));
  }

  void _broadcastWs(WsMessage message) {
    final encoded = jsonEncode(message.toJson());
    for (final channel in _clients.values) {
      channel.sink.add(encoded);
    }
  }

  void notifySyncConfirmed() {
    _broadcastWs(const WsMessage(type: WsMessageType.syncConfirmed));
  }

  void notifySyncReset() {
    _broadcastWs(const WsMessage(type: WsMessageType.syncReset));
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
              final connectAction = WsConnectAction.fromJson(json);

              clientId = connectAction.clientId ?? repo.generateClientId();
              _clients[clientId!] = channel;

              repo.addClient(clientId!, connectAction.deviceName);

              final response = WsConnectedData(
                clientId: clientId!,
                phase: repo.phase,
              );
              _sendWs(channel, response.toMessage());

            default:
              _sendWs(
                channel,
                WsErrorData(message: 'Unknown action: $action').toMessage(),
              );
          }
        } catch (e) {
          _sendWs(channel, WsErrorData(message: e.toString()).toMessage());
        }
      },
      onDone: () {
        if (clientId != null) {
          _clients.remove(clientId);
          repo.removeClient(clientId!);
        }
      },
      onError: (error) {
        if (clientId != null) {
          _clients.remove(clientId);
          repo.removeClient(clientId!);
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
    final clients = repo.connectedClients;
    final dto = HubStatusDto(
      isRunning: true,
      serverUrl: serverUrl,
      phase: repo.phase.name,
      connectedClients: clients.map(ConnectedClientDto.fromModel).toList(),
      totalStagedClients: clients.where((c) => c.hasStaged).length,
      totalPulledClients: clients.where((c) => c.hasPulled).length,
      pullProgress: _buildPullProgress(clients),
      conflictsCount: 0,
      hasUnresolvedConflicts: false,
      canConfirm: false,
    );
    return _jsonResponse(dto.toJson());
  }

  String _buildPullProgress(List<ConnectedClient> clients) {
    final staged = clients.where((c) => c.hasStaged).length;
    if (staged == 0) return '';
    final pulled = clients.where((c) => c.hasPulled).length;
    return '$pulled/$staged';
  }

  Response _handleSyncStatus() {
    final dto = SyncStatusDto(
      phase: repo.phase.name,
      canPull: repo.canPull,
    );
    return _jsonResponse(dto.toJson());
  }

  Future<Response> _handleStageBegin(Request request) async {
    if (!repo.canStage) {
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

      repo.beginStaging(dto.clientId!, dto.expectedSources);

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

      final client = repo.getClient(dto.clientId!);

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

      repo.completeStaging(dto.clientId!);

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
    if (!repo.canStage) {
      return Response(400, body: 'Sync session in progress, cannot stage');
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final dto = StageRequestDto.fromJson(json);

      if (dto.clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      repo.stageData(dto.clientId!, sourceId, dto.data);

      final responseDto = StageResponseDto(stagedCount: dto.data.length);
      return _jsonResponse(responseDto.toJson());
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'error': e.toString()}),
      );
    }
  }

  Response _handlePull(String sourceId) {
    if (!repo.canPull) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    final resolvedData = repo.getResolvedDataForSource(sourceId);
    if (resolvedData == null) {
      return Response.notFound('No resolved data for: $sourceId');
    }

    final dto = PullResponseDto(data: resolvedData);
    return _jsonResponse(dto.toJson());
  }

  Response _handlePullAll() {
    if (!repo.canPull) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    final dto = PullAllResponseDto(sources: repo.resolvedData);
    return _jsonResponse(dto.toJson());
  }

  Future<Response> _handlePullComplete(Request request) async {
    if (!repo.canPull) {
      return Response(400, body: 'Sync not confirmed yet');
    }

    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final clientId = json['clientId'] as String?;

      if (clientId == null) {
        return Response(400, body: 'Missing clientId');
      }

      repo.completePull(clientId);

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
