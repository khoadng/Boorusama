// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:shelf/shelf.dart';

// Project imports:
import '../../../foundation/loggers/logger.dart';

class ServerConfig {
  const ServerConfig({
    required this.serverName,
    required this.appVersion,
    required this.logger,
    required this.routes,
    required this.onError,
    this.requestTimeout = const Duration(seconds: 30),
    this.enableRetry = true,
  });

  final String serverName;
  final String appVersion;
  final Logger logger;
  final Map<String, Handler> routes;
  final void Function(String message) onError;
  final Duration requestTimeout;
  final bool enableRetry;
}

class ServerInfo {
  const ServerInfo({
    required this.host,
    required this.port,
  });

  final String host;
  final int port;

  String get url => 'http://$host:$port';
}

abstract class AppServerInterface {
  bool get isRunning;
  bool get isBroadcasting;
  ServerInfo? get serverInfo;
  String get serverName;
  String get appVersion;

  Future<ServerInfo?> startServer(String address);
  Future<void> startBroadcast();
  Future<void> stopServer();
  Future<void> dispose();
}

class DiscoveredService {
  const DiscoveredService({
    required this.name,
    required this.host,
    required this.port,
    required this.attributes,
  });

  final String name;
  final String host;
  final int port;
  final Map<String, String> attributes;

  String get url => 'http://$host:$port';
}

abstract class DiscoveryClientInterface {
  bool get isDiscovering;

  Future<void> startDiscovery({
    Duration timeout = const Duration(seconds: 30),
  });

  Future<void> stopDiscovery();
}

class ExportDataPayload {
  const ExportDataPayload({
    required this.version,
    required this.exportDate,
    required this.data,
    required this.exportVersion,
  });

  const ExportDataPayload.legacy({
    required this.data,
  }) : version = 1,
       exportDate = null,
       exportVersion = null;

  final int version;
  final DateTime? exportDate;
  final Version? exportVersion;
  final List<dynamic> data;

  Map<String, dynamic> toJson() => {
    'version': version,
    'exportVersion': ?exportVersion?.toString(),
    'date': ?exportDate?.toIso8601String(),
    'data': data,
  };
}

class InvalidBackupFormatException implements Exception {
  const InvalidBackupFormatException();
}

class ExportCategory {
  const ExportCategory({
    required this.name,
    required this.displayName,
    required this.route,
    required this.handler,
  });

  final String displayName;
  final String name;
  final String route;
  final Handler handler;
}
