// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../foundation/keyboard/keyboard.dart';

const kPostDetailsNextPage = 'post.details.nextPage';
const kPostDetailsPreviousPage = 'post.details.previousPage';
const kPostDetailsToggleOverlay = 'post.details.toggleOverlay';
const kPostDetailsClose = 'post.details.close';
const kPostDetailsViewOriginal = 'post.details.viewOriginal';

final postDetailsShortcuts = [
  ShortcutActionInfo(
    id: kPostDetailsNextPage,
    context: ShortcutContext.postDetails,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.arrowRight.keyId),
    labelBuilder: (context) => context.t.settings.keybinds.actions.next_post,
  ),
  ShortcutActionInfo(
    id: kPostDetailsPreviousPage,
    context: ShortcutContext.postDetails,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.arrowLeft.keyId),
    labelBuilder: (context) =>
        context.t.settings.keybinds.actions.previous_post,
  ),
  ShortcutActionInfo(
    id: kPostDetailsToggleOverlay,
    context: ShortcutContext.postDetails,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.keyO.keyId),
    labelBuilder: (context) =>
        context.t.settings.keybinds.actions.toggle_overlay,
  ),
  ShortcutActionInfo(
    id: kPostDetailsClose,
    context: ShortcutContext.postDetails,
    defaultBinding: KeyBinding(key: LogicalKeyboardKey.escape.keyId),
    labelBuilder: (context) => context.t.settings.keybinds.actions.close_viewer,
  ),
  ShortcutActionInfo(
    id: kPostDetailsViewOriginal,
    context: ShortcutContext.postDetails,
    defaultBinding: KeyBinding(
      key: LogicalKeyboardKey.keyF.keyId,
      primaryModifier: true,
    ),
    labelBuilder: (context) =>
        context.t.settings.keybinds.actions.view_original_image,
  ),
];
