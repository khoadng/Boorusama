// Dart imports:
import 'dart:async';
import 'dart:io';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

// Project imports:
import '../../../foundation/info/device_info.dart';
import '../../../foundation/info/package_info.dart';
import '../../../foundation/loggers.dart';
import '../../../foundation/networking.dart';
import '../sources/providers.dart';
import '../types.dart';

const _kServerName = 'App Server';

final dataSyncServerProvider = Provider<AppServerInterface>((ref) {
  final registry = ref.watch(backupRegistryProvider);

  final config = ServerConfig(
    logger: ref.watch(loggerProvider),
    serverName: ref.watch(deviceInfoProvider).deviceName ?? 'Unknown server',
    appVersion: ref.watch(packageInfoProvider).version,
    onError: (message) {
      ref.read(loggerProvider).error('DataSyncServer', message);
    },
    routes: {
      'health': (request) => Response(204),
      for (final source in registry.getAllSources())
        source.id: source.capabilities.server.export,
    },
  );

  final server = AppServer.fromConfig(config);

  // Wifi is required since our transfer protocol is within the local network.
  ref
    ..listen(
      connectedToWifiProvider,
      (previous, next) {
        if (next != previous) {
          if (next) {
            server.dispose();
          }
        }
      },
    )
    ..onDispose(server.dispose);

  return server;
});

class AppServer implements AppServerInterface {
  AppServer(this._config);

  factory AppServer.fromConfig(ServerConfig config) => AppServer(config);

  final ServerConfig _config;

  var _isRunning = false;
  var _isBroadcasting = false;
  ServerInfo? _serverInfo;

  HttpServer? _server;
  BonsoirBroadcast? _broadcast;

  HttpServer? get server => _server;

  @override
  bool get isRunning => _isRunning;

  @override
  bool get isBroadcasting => _isBroadcasting;

  @override
  ServerInfo? get serverInfo => _serverInfo;

  @override
  String get serverName => _config.serverName;

  @override
  String get appVersion => _config.appVersion;

  @override
  Future<void> dispose() async {
    await stopServer();
  }

  @override
  Future<ServerInfo?> startServer(String address) async {
    if (_isRunning) return _serverInfo;

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
            _config.requestTimeout,
            onTimeout: () => throw TimeoutException('Server start timeout'),
          );

      _config.logger.info(
        _kServerName,
        'Server running on http://${server.address.host}:${server.port}',
      );

      _server = server;
      _serverInfo = ServerInfo(
        host: server.address.host,
        port: server.port,
      );
      _isRunning = true;

      return _serverInfo;
    } catch (e) {
      _isRunning = false;
      _config.logger.error(_kServerName, 'Failed to start server: $e');
      _config.onError('Failed to start server: $e');
      return null;
    }
  }

  @override
  Future<void> startBroadcast() async {
    var retries = 0;
    const maxRetries = 3;

    final server = _server;
    if (server == null || !_isRunning) return;

    while (retries < maxRetries) {
      try {
        final service = BonsoirService(
          name: _config.serverName,
          type: '_boorusama._tcp',
          port: server.port,
          attributes: {
            'server': 'boorusama',
            'version': _config.appVersion,
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
        if (retries == maxRetries || !_config.enableRetry) {
          _config.logger.error(
            _kServerName,
            'Broadcast failed after $retries attempts: $e',
          );
          _config.onError('Broadcast failed: $e');
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * retries));
      }
    }
  }

  @override
  Future<void> stopServer() async {
    try {
      await _broadcast?.stop();
      await _server?.close(force: true);

      _broadcast = null;
      _server = null;
      _serverInfo = null;
      _isRunning = false;
      _isBroadcasting = false;

      _config.logger.info(_kServerName, 'Server stopped');
    } catch (e) {
      _config.logger.error(_kServerName, 'Stop server failed: $e');
      _config.onError('Stop server failed: $e');
    }
  }

  Future<Response> _handleRequest(Request request) async {
    final path = request.url.path;
    final handler = _config.routes[path];

    if (handler != null) {
      return handler(request);
    }

    return Response.notFound('Not found: $path');
  }

  Middleware _validateRequestMiddleware() {
    return (Handler innerHandler) {
      return (Request request) {
        if (!['GET', 'POST'].contains(request.method)) {
          return Response.forbidden('Method not allowed');
        }
        return innerHandler(request);
      };
    };
  }
}
