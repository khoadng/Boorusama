// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Project imports:
import '../foundation/loggers/logger.dart';

const _kServerName = 'App Server';

class AppServer {
  AppServer({
    required this.onError,
    required this.routes,
    required this.serverName,
    required this.appVersion,
    required this.logger,
  });

  var _isRunning = false;

  final Map<String, Handler> routes;
  final String serverName;
  final String appVersion;

  final Logger logger;

  HttpServer? _server;
  final void Function(String message) onError;
  bool get isRunning => _isRunning;
  BonsoirBroadcast? _broadcast;

  HttpServer? get server => _server;

  void dispose() {
    stopServer();
  }

  Future<HttpServer?> startServer(String address) async {
    try {
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addHandler(_handleRequest);

      final server = await serve(
        handler,
        address,
        0,
      );

      logger.logI(
        _kServerName,
        'Server running on http://${server.address.host}:${server.port}',
      );

      _server = server;
      _isRunning = true;

      return _server;
    } catch (e) {
      logger.logE(_kServerName, 'Failed to start server: $e');

      onError('Failed to start server: $e');

      return null;
    }
  }

  Future<void> startBroadcast() async {
    final server = _server;

    if (server == null) return;

    // Setup Bonsoir service
    final service = BonsoirService(
      name: serverName,
      type: '_boorusama._tcp',
      port: server.port,
      attributes: {
        'server': 'boorusama',
        'version': appVersion,
        'ip': server.address.host,
        'port': server.port.toString(),
      },
    );

    // Start broadcasting
    _broadcast = BonsoirBroadcast(service: service);
    await _broadcast?.ready;
    await _broadcast?.start();
  }

  void stopServer() {
    _server?.close(force: true);
    _server = null;

    _broadcast?.stop();
    _broadcast = null;
    _isRunning = false;

    logger.logI(_kServerName, 'Server stopped');
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final handler = routes[path];

    if (handler != null) {
      return handler(request);
    }

    return Response.notFound('Not found: $path');
  }
}
