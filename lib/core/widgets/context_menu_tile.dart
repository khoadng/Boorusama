// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';

class ContextMenuTile extends ConsumerWidget {
  const ContextMenuTile({
    required this.title,
    super.key,
    this.onTap,
    this.enabled = true,
    this.hideOnTap = true,
  });

  final String title;
  final VoidCallback? onTap;
  final bool enabled;
  final bool hideOnTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
        ),
        constraints: const BoxConstraints(
          minWidth: 200,
        ),
        child: InkWell(
          hoverColor: enabled ? colorScheme.primary : Colors.transparent,
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          onTap: enabled
              ? () {
                  if (hideOnTap) {
                    context.hideMenu();
                  }

                  if (hapticLevel.isFull) {
                    HapticFeedback.selectionClick();
                  }
                  onTap?.call();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: enabled
                    ? colorScheme.onSurface
                    : colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
