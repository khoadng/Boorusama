// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/foundation/android.dart';
import 'package:boorusama/foundation/device_info_service.dart';
import 'package:boorusama/foundation/platform.dart';

const _kDefaultMaxCachedControllers = 3;

class VideoWidgetManager {
  static final VideoWidgetManager _instance = VideoWidgetManager._internal();
  factory VideoWidgetManager() => _instance;
  VideoWidgetManager._internal();

  final Map<String, VideoPlayerController> _controllers = {};
  final Set<String> _activeUrls = {};
  var _maxCachedControllers = _kDefaultMaxCachedControllers;

  int get maxCachedControllers => _maxCachedControllers;
  set maxCachedControllers(int value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'maxCachedControllers',
          'maxCachedControllers must be greater than or equal to 0');
    }

    if (value < _controllers.length) {
      throw ArgumentError.value(value, 'maxCachedControllers',
          'maxCachedControllers must be greater than or equal to the number of active controllers');
    }

    if (value == _maxCachedControllers) return;

    _maxCachedControllers = value;
    _cleanupInactiveControllers();
  }

  String _getUrlHash(String url) {
    return sha256.convert(utf8.encode(url)).toString().substring(0, 10);
  }

  Future<VideoPlayerController> registerVideo(Uri videoUrl) async {
    _debugLog('Registering video: $videoUrl');

    final urlHash = _getUrlHash(videoUrl.toString());
    _activeUrls.add(urlHash);

    if (_controllers.containsKey(urlHash)) {
      _debugLog('Video already registered: $videoUrl');

      final controller = _controllers[urlHash]!;

      return controller;
    }

    try {
      final controller = VideoPlayerController.networkUrl(videoUrl);
      await controller.initialize();
      _debugLog('Video registered: $videoUrl');
      _controllers[urlHash] = controller;
      controller.play();
      _cleanupInactiveControllers();

      return controller;
    } catch (e) {
      _activeUrls.remove(urlHash);
      rethrow;
    }
  }

  void unregisterVideo(String videoUrl) {
    _debugLog('Unregistering video: $videoUrl');
    final urlHash = _getUrlHash(videoUrl);

    if (!_activeUrls.contains(urlHash) || !_controllers.containsKey(urlHash)) {
      _debugLog('Video not registered: $videoUrl');
      return;
    }

    _controllers[urlHash]?.pause();

    _activeUrls.remove(urlHash);

    if (!_shouldKeepController(urlHash)) {
      _debugLog('Disposing controller: $videoUrl');
      _controllers[urlHash]?.dispose();
      _controllers.remove(urlHash);
    }
  }

  bool _shouldKeepController(String urlHash) {
    return _activeUrls.contains(urlHash) ||
        _controllers.length <= maxCachedControllers;
  }

  void _cleanupInactiveControllers() {
    if (_controllers.length > maxCachedControllers) {
      _debugLog('Cleaning up inactive controllers');
      final inactiveControllers = _controllers.keys
          .where((hash) => !_activeUrls.contains(hash))
          .take(_controllers.length - maxCachedControllers);

      for (final hash in inactiveControllers) {
        _debugLog('Disposing controller: $hash');
        _controllers[hash]?.dispose();
        _controllers.remove(hash);
      }
    }
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _activeUrls.clear();
  }
}

void _debugLog(String message) {
  if (!kDebugMode) return;
  // ignore: avoid_print
  print('[VideoManager] $message');
}

int determineMaxCachedControllers(DeviceInfo deviceInfo) {
  // Only handle Android devices for now
  if (!isAndroid()) return _kDefaultMaxCachedControllers;

  final androidVersion = deviceInfo.androidDeviceInfo?.version.sdkInt;

  if (androidVersion == null) return _kDefaultMaxCachedControllers;

  // Just some arbitrary values pulled right out of thin air
  return switch (androidVersion) {
    < AndroidVersions.android7_1 => 1,
    < AndroidVersions.android10 => 2,
    < AndroidVersions.android13 => 3,
    _ => 4,
  };
}

class VideoControllerScope extends StatefulWidget {
  const VideoControllerScope({
    super.key,
    required this.deviceInfo,
    required this.child,
  });

  final DeviceInfo deviceInfo;
  final Widget child;

  @override
  State<VideoControllerScope> createState() =>
      _VideoPlayerControllerScopeState();
}

class _VideoPlayerControllerScopeState extends State<VideoControllerScope>
    with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      VideoWidgetManager().dispose();
    }
  }

  @override
  void initState() {
    super.initState();

    VideoWidgetManager().maxCachedControllers =
        determineMaxCachedControllers(widget.deviceInfo);

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VideoPlayerControllerNavigatorObserver extends NavigatorObserver {
  VideoPlayerControllerNavigatorObserver({
    required this.targetRoutes,
  });

  final List<String> targetRoutes;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final routeName = route.settings.name;

    if (routeName != null && targetRoutes.contains(routeName)) {
      _debugLog('Cleaning up video controllers');
      VideoWidgetManager().dispose();
    }

    super.didPop(route, previousRoute);
  }
}
