// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/settings/types.dart';

class InstanceListener extends ConsumerStatefulWidget {
  const InstanceListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<InstanceListener> createState() => _InstanceListenerState();
}

class _InstanceListenerState extends ConsumerState<InstanceListener> {
  static const platform = MethodChannel('com.degenk.boorusama/instance');

// Get battery level.
  String _batteryLevel = 'Unknown battery level.';

  @override
  void initState() {
    super.initState();
    _getBatteryLevel();
  }

  Future<void> launchNewInstance() async {
    try {
      await platform.invokeMethod(
          'launchNewInstance', {'sessionData': 'your-session-data'});
    } on PlatformException catch (e) {
      print("Failed to launch new instance: '${e.message}'.");
    }
  }

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;

      print(_batteryLevel);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// Add this class to store session data
class SessionData {
  final String id;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final BooruConfig config;
  final Settings settings;

  SessionData({
    required this.id,
    required this.data,
    DateTime? createdAt,
    required this.config,
    required this.settings,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SessionData.fromJson(Map<String, dynamic> json) => SessionData(
        id: json['id'],
        data: json['data'],
        createdAt: DateTime.parse(json['createdAt']),
        config: BooruConfig.fromJson(json['config']),
        settings: Settings.fromJson(json['settings']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'config': config.toJson(),
        'settings': settings.toJson(),
      };
}

class AppInstanceServer {
  static const int _defaultPort = 4040;
  static AppInstanceServer? _instance;
  HttpServer? _httpServer;

  static const platform = MethodChannel('com.degenk.boorusama/instance');

  static SessionData? _session;

  Future<void> launchNewInstance(BooruConfig config, Settings settings) async {
    final sessionId = Uuid().v4();
    final session = SessionData(
      id: sessionId,
      data: {},
      config: config,
      settings: settings,
    );

    _session = session;

    try {
      await platform.invokeMethod(
        'launchNewInstance',
        {
          'sessionData': jsonEncode(session.toJson()),
        },
      );
    } on PlatformException catch (e) {
      print("Failed to launch new instance: '${e.message}'.");
    }
  }

  AppInstanceServer._();

  static AppInstanceServer get instance {
    _instance ??= AppInstanceServer._();
    return _instance!;
  }

  /// Creates and returns server instance, null if already running
  Future<HttpServer?> createServer({int port = _defaultPort}) async {
    if (_httpServer != null) return null;

    try {
      final server = await HttpServer.bind(
        InternetAddress.loopbackIPv4,
        port,
        shared: false,
      );

      _httpServer = server;

      server.listen((HttpRequest request) async {
        if (request.method == 'GET' && request.uri.path == '/session') {
          if (_session != null) {
            final session = _session;
            if (session != null) {
              request.response
                ..headers.contentType = ContentType.json
                ..write(jsonEncode(session.toJson()))
                ..close();
              return;
            }
          }
        }

        request.response
          ..statusCode = HttpStatus.notFound
          ..close();
      });

      return server;
    } catch (e) {
      return null;
    }
  }

  HttpServer? get server => _httpServer;

  bool get isRunning => _httpServer != null;

  Future<void> dispose() async {
    await _httpServer?.close();
    _httpServer = null;
  }
}

class AppInstanceClient {
  Future<SessionData?> getSession() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:4040/session'));
      if (response.statusCode == 200) {
        return SessionData.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      return null;
    }

    return null;
  }
}

class LaunchNewInstanceButton extends ConsumerWidget {
  const LaunchNewInstanceButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;
    final settings = ref.watch(settingsProvider);

    return ElevatedButton(
      onPressed: () {
        AppInstanceServer.instance.launchNewInstance(config, settings);
      },
      child: const Text('Detach this profile to a new instance'),
    );
  }
}
