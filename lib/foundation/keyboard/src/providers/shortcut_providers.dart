// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/shortcut_binding_config.dart';
import '../types/shortcut_registry.dart';

final shortcutRegistryProvider = Provider<KeybindRegistry>(
  (ref) => throw UnimplementedError(),
  name: 'shortcutRegistryProvider',
);

final shortcutBindingConfigProvider = Provider<ShortcutBindingConfig>(
  (ref) => throw UnimplementedError(),
  name: 'shortcutBindingConfigProvider',
);
