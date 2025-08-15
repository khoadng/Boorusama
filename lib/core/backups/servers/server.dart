// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Project imports:
import '../../../foundation/loggers/logger.dart';

const _kServerName = 'App Server';

class AppServer {
  // Add configuration
  AppServer({
    required this.onError,
    required this.routes,
    required this.serverName,
    required this.appVersion,
    required this.logger,
    this.requestTimeout = const Duration(seconds: 30),
    this.enableRetry = true,
  });

  var _isRunning = false;
  var _isBroadcasting = false;

  final Map<String, Handler> routes;
  final String serverName;
  final String appVersion;

  final Logger logger;

  HttpServer? _server;
  final void Function(String message) onError;
  bool get isRunning => _isRunning;
  bool get isBroadcasting => _isBroadcasting;
  BonsoirBroadcast? _broadcast;

  HttpServer? get server => _server;

  final Duration requestTimeout;
  final bool enableRetry;

  Future<void> dispose() async {
    await stopServer();
  }

  Future<HttpServer?> startServer(String address) async {
    if (_isRunning) return _server;

    try {
      final handler = const Pipeline()
          .addMiddleware(logRequests())
          .addMiddleware(_validateRequestMiddleware())
          .addHandler(_handleRequest);

      final server =
          await serve(
            handler,
            address,
            0,
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw TimeoutException('Server start timeout'),
          );

      logger.info(
        _kServerName,
        'Server running on http://${server.address.host}:${server.port}',
      );

      _server = server;
      _isRunning = true;

      return _server;
    } catch (e) {
      _isRunning = false;
      logger.error(_kServerName, 'Failed to start server: $e');
      onError('Failed to start server: $e');
      return null;
    }
  }

  Future<void> startBroadcast() async {
    var retries = 0;
    const maxRetries = 3;

    final server = _server;
    if (server == null || !_isRunning) return;

    while (retries < maxRetries) {
      try {
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

        _broadcast = BonsoirBroadcast(service: service);
        await _broadcast?.initialize();
        await _broadcast?.start();

        _isBroadcasting = true;

        break;
      } catch (e) {
        retries++;
        if (retries == maxRetries || !enableRetry) {
          logger.error(
            _kServerName,
            'Broadcast failed after $retries attempts: $e',
          );
          onError('Broadcast failed: $e');
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * retries));
      }
    }
  }

  Future<void> stopServer() async {
    try {
      await _broadcast?.stop();
      await _server?.close(force: true);

      _broadcast = null;
      _server = null;
      _isRunning = false;

      logger.info(_kServerName, 'Server stopped');
    } catch (e) {
      logger.error(_kServerName, 'Stop server failed: $e');
      onError('Stop server failed: $e');
    }
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final handler = routes[path];

    if (handler != null) {
      return handler(request);
    }

    return Response.notFound('Not found: $path');
  }

  Middleware _validateRequestMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (!['GET', 'POST'].contains(request.method)) {
          return Response.forbidden('Method not allowed');
        }
        return innerHandler(request);
      };
    };
  }
}
