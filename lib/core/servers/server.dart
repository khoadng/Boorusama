// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';

class AppServer {
  AppServer({
    required this.onError,
    required this.routes,
  });

  final Map<String, Handler> routes;

  HttpServer? _server;
  final void Function(String message) onError;
  final ValueNotifier<bool> isRunning = ValueNotifier(false);
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

      print('Server running on http://${server.address.host}:${server.port}');

      // Setup Bonsoir service
      final service = BonsoirService(
        name: 'Boorusama Server',
        type: '_boorusama._tcp',
        port: server.port,
        attributes: {
          'server': 'boorusama',
          'ip': address,
          'port': server.port.toString(),
        },
      );

      // Start broadcasting
      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast?.ready;
      await _broadcast?.start();

      _server = server;
      isRunning.value = true;

      return _server;
    } catch (e) {
      onError('Failed to start server: $e');
      return null;
    }
  }

  void stopServer() {
    _server?.close(force: true);
    _server = null;

    _broadcast?.stop();
    _broadcast = null;
    isRunning.value = false;

    print('Server stopped');
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

class AppClient {
  AppClient({
    this.onError,
    this.onServiceFound,
    this.onServiceResolved,
    this.onServiceLost,
  });

  BonsoirDiscovery? _discovery;
  StreamSubscription? _discoverySubscription;
  final void Function(String message)? onError;
  final void Function(BonsoirService service)? onServiceFound;
  final void Function(BonsoirService service)? onServiceResolved;
  final void Function(BonsoirService service)? onServiceLost;

  Future<void> startDiscovery() async {
    try {
      _discovery = BonsoirDiscovery(type: '_boorusama._tcp');
      await _discovery?.ready;

      _discoverySubscription = _discovery?.eventStream?.listen((event) {
        switch (event.type) {
          case BonsoirDiscoveryEventType.discoveryServiceFound:
            final service = event.service;
            if (service != null) {
              onServiceFound?.call(service);
              service.resolve(_discovery!.serviceResolver);
            }
            break;
          case BonsoirDiscoveryEventType.discoveryServiceResolved:
            if (event.service != null) {
              onServiceResolved?.call(event.service!);
            }
            break;
          case BonsoirDiscoveryEventType.discoveryServiceLost:
            if (event.service != null) {
              onServiceLost?.call(event.service!);
            }
            break;
          default:
            onError?.call('Unknown discovery event: ${event.type}');
        }
      });

      await _discovery?.start();
    } catch (e) {
      onError?.call('Failed to start discovery: $e');
    }
  }

  void stopDiscovery() {
    _discoverySubscription?.cancel();
    _discoverySubscription = null;
    _discovery?.stop();
    _discovery = null;
  }

  void dispose() {
    stopDiscovery();
  }

  bool get isDiscovering => _discovery != null;
}
