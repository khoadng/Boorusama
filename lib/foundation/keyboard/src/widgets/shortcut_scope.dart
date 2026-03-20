// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../providers/shortcut_providers.dart';

class ShortcutScope extends ConsumerWidget {
  const ShortcutScope({
    required this.handlers,
    required this.child,
    this.autofocus = false,
    super.key,
  });

  final Map<String, VoidCallback> handlers;
  final Widget child;
  final bool autofocus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(shortcutBindingConfigProvider);

    final bindings = <ShortcutActivator, VoidCallback>{};
    for (final entry in handlers.entries) {
      final binding = config.bindingFor(entry.key);
      if (binding != null) {
        bindings[binding.toSingleActivator()] = entry.value;
      }
    }

    return CallbackShortcuts(
      bindings: bindings,
      child: autofocus ? Focus(autofocus: true, child: child) : child,
    );
  }
}
