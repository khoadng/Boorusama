// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../settings/providers.dart';

class ContextMenuTile extends ConsumerWidget {
  const ContextMenuTile({
    required this.title,
    super.key,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final VoidCallback? onTap;
  final bool enabled;

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
              ? hapticLevel.isFull
                    ? () {
                        HapticFeedback.selectionClick();
                        onTap?.call();
                      }
                    : onTap
              : null,
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: isMobilePlatform() ? 12 : 8,
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
