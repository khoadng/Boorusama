// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'app_lock_type.dart';

class AppLockSessionConfig {
  const AppLockSessionConfig({
    required this.type,
    required this.timeout,
    required this.hideAppPreviewWhenBackgrounded,
  });

  final AppLockType type;
  final Duration timeout;
  final bool hideAppPreviewWhenBackgrounded;
}

class AppLockSession {
  AppLockSession({
    required AppLockSessionConfig config,
    required DateTime Function() now,
  }) : _config = config,
       _now = now,
       _locked = config.type.appLockEnabled;

  AppLockSessionConfig _config;
  final DateTime Function() _now;
  bool _locked;
  var _privacyCoverVisible = false;
  DateTime? _backgroundedAt;

  bool get locked => _locked;
  bool get privacyCoverVisible => _privacyCoverVisible;

  void updateConfig(AppLockSessionConfig config) {
    final oldConfig = _config;
    _config = config;

    if (!config.hideAppPreviewWhenBackgrounded) {
      _privacyCoverVisible = false;
    }

    if (!config.type.appLockEnabled) {
      _locked = false;
      _backgroundedAt = null;
      return;
    }

    if (!oldConfig.type.appLockEnabled && config.type.appLockEnabled) {
      // Enabling the lock from settings should not immediately cover settings.
      _locked = false;
      _privacyCoverVisible = false;
      return;
    }

    if (oldConfig.type != config.type) {
      _locked = true;
      _privacyCoverVisible = false;
    }
  }

  void unlock() {
    _locked = false;
    _privacyCoverVisible = false;
    _backgroundedAt = null;
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        _backgroundedAt ??= _now();
        if (_config.hideAppPreviewWhenBackgrounded) {
          _privacyCoverVisible = true;
        }
        if (_config.type.appLockEnabled && _config.timeout == Duration.zero) {
          _locked = true;
        }
      case AppLifecycleState.resumed:
        final backgroundedAt = _backgroundedAt;
        _backgroundedAt = null;
        _privacyCoverVisible = false;

        if (_config.type.appLockEnabled &&
            backgroundedAt != null &&
            _now().difference(backgroundedAt) >= _config.timeout) {
          _locked = true;
        }
      case AppLifecycleState.detached:
        break;
    }
  }
}
