// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/shortcut_providers.dart';

class GlobalShortcutScope extends ConsumerStatefulWidget {
  const GlobalShortcutScope({
    required this.handlers,
    required this.child,
    super.key,
  });

  final Map<String, VoidCallback> handlers;
  final Widget child;

  @override
  ConsumerState<GlobalShortcutScope> createState() =>
      _GlobalShortcutScopeState();
}

class _GlobalShortcutScopeState extends ConsumerState<GlobalShortcutScope> {
  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    final config = ref.read(shortcutBindingConfigProvider);

    for (final entry in widget.handlers.entries) {
      final binding = config.bindingFor(entry.key);
      if (binding != null &&
          binding.matchesEvent(event, HardwareKeyboard.instance)) {
        entry.value();
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
