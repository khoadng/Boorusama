// Package imports:
import 'package:window_manager/window_manager.dart' as window_manager;

// Project imports:
import 'window_service.dart';

final class PluginWindowService implements WindowService {
  PluginWindowService({window_manager.WindowManager? windowManager})
    : _windowManager = windowManager ?? window_manager.windowManager;

  final window_manager.WindowManager _windowManager;

  @override
  Future<bool> isAlwaysOnTop() => _windowManager.isAlwaysOnTop();

  @override
  Future<void> setAlwaysOnTop(bool value) =>
      _windowManager.setAlwaysOnTop(value);
}
