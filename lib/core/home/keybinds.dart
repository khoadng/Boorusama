// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/keyboard/keyboard.dart';

const kHomeRefresh = 'home.refresh';

final homeShortcuts = [
  ShortcutActionInfo(
    id: kHomeRefresh,
    context: ShortcutContext.home,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.f5.keyId),
    labelBuilder: (context) => context.t.settings.keybinds.actions.refresh,
  ),
];
