// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'key_binding.dart';
import 'shortcut_action.dart';
import 'shortcut_binding_config.dart';

typedef ShortcutLabelBuilder = String Function(BuildContext context);

class ShortcutActionInfo {
  const ShortcutActionInfo({
    required this.id,
    required this.context,
    required this.defaultBinding,
    required this.labelBuilder,
  });

  final String id;
  final ShortcutContext context;
  final KeyBinding defaultBinding;
  final ShortcutLabelBuilder labelBuilder;
}

class KeybindRegistry {
  KeybindRegistry(List<ShortcutActionInfo> actions)
    : _actions = {for (final a in actions) a.id: a};

  final Map<String, ShortcutActionInfo> _actions;

  List<ShortcutActionInfo> get actions => _actions.values.toList();

  ShortcutActionInfo? actionFor(String id) => _actions[id];

  ShortcutContext? contextFor(String id) => _actions[id]?.context;

  String labelFor(BuildContext context, String id) =>
      _actions[id]?.labelBuilder(context) ?? id;

  ShortcutBindingConfig defaultBindings() {
    return ShortcutBindingConfig(
      bindings: {
        for (final a in _actions.values) a.id: a.defaultBinding,
      },
    );
  }

  /// Returns the action ID of a conflicting binding within the same context,
  /// or null if there is no conflict.
  String? findConflict(
    String actionId,
    KeyBinding binding,
    ShortcutBindingConfig config,
  ) {
    final targetContext = contextFor(actionId);

    for (final entry in config.bindings.entries) {
      if (entry.key == actionId) continue;
      if (contextFor(entry.key) != targetContext) continue;
      if (entry.value == binding) return entry.key;
    }

    return null;
  }

  Map<ShortcutContext, List<ShortcutActionInfo>> get grouped {
    final result = <ShortcutContext, List<ShortcutActionInfo>>{};
    for (final action in _actions.values) {
      result.putIfAbsent(action.context, () => []).add(action);
    }
    return result;
  }
}
