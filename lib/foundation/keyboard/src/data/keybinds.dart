// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../types/key_binding.dart';
import '../types/shortcut_action.dart';
import '../types/shortcut_registry.dart';

const kGlobalToggleSidebar = 'global.toggleSidebar';
const kGlobalBack = 'global.back';

final globalShortcuts = [
  ShortcutActionInfo(
    id: kGlobalBack,
    context: ShortcutContext.global,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.escape.keyId),
    labelBuilder: (context) => context.t.settings.keybinds.actions.go_back,
  ),
  ShortcutActionInfo(
    id: kGlobalToggleSidebar,
    context: ShortcutContext.global,
    defaultBinding: KeyBinding(
      key: LogicalKeyboardKey.keyB.keyId,
      primaryModifier: true,
    ),
    labelBuilder: (context) =>
        context.t.settings.keybinds.actions.toggle_sidebar,
  ),
];
