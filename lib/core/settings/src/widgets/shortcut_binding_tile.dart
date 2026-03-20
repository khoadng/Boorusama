// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/keyboard/keyboard.dart';

class ShortcutBindingTile extends StatelessWidget {
  const ShortcutBindingTile({
    required this.label,
    required this.binding,
    required this.onTap,
    super.key,
  });

  final String label;
  final KeyBinding? binding;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: Text(label),
      trailing: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: binding != null
            ? _KeyCaps(parts: binding!.displayParts(), colorScheme: colorScheme)
            : _KeyCap(
                label: context.t.settings.keybinds.not_set,
                colorScheme: colorScheme,
                dimmed: true,
              ),
      ),
    );
  }
}

class _KeyCaps extends StatelessWidget {
  const _KeyCaps({
    required this.parts,
    required this.colorScheme,
  });

  final List<String> parts;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          _KeyCap(label: parts[i], colorScheme: colorScheme),
          if (i < parts.length - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }
}

class _KeyCap extends StatelessWidget {
  const _KeyCap({
    required this.label,
    required this.colorScheme,
    this.dimmed = false,
  });

  final String label;
  final ColorScheme colorScheme;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 32),
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          color: dimmed ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
        ),
      ),
    );
  }
}
