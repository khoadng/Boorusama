import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class WindowService {
  Future<bool> isAlwaysOnTop();

  Future<void> setAlwaysOnTop(bool value);
}

final windowServiceProvider = Provider<WindowService>(
  (_) => throw UnimplementedError(),
  name: 'windowServiceProvider',
);
