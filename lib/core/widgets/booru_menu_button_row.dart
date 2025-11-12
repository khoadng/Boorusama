// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';
import 'adaptive_button_row.dart';

class BooruMenuButtonRow extends ConsumerWidget {
  const BooruMenuButtonRow({
    required this.buttons,
    this.buttonWidth,
    this.spacing = 8,
    this.overflowIcon,
    this.overflowButtonBuilder,
    this.onOverflow,
    this.maxVisibleButtons,
    this.alignment,
    this.padding,
    this.onOpened,
    this.onClosed,
    this.onMenuTap,
    super.key,
  });

  final List<ButtonData> buttons;
  final double? buttonWidth;
  final double spacing;
  final Widget? overflowIcon;
  final Widget Function(VoidCallback)? overflowButtonBuilder;
  final ValueChanged<int>? onOverflow;
  final int? maxVisibleButtons;
  final MainAxisAlignment? alignment;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onOpened;
  final VoidCallback? onClosed;
  final VoidCallback? onMenuTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);
    final reduceAnimation = ref.watch(
      settingsProvider.select(
        (value) => value.reduceAnimations,
      ),
    );

    return AdaptiveButtonRow.menu(
      buttons: buttons,
      buttonWidth: buttonWidth,
      spacing: spacing,
      overflowIcon: overflowIcon,
      onOverflow: onOverflow,
      maxVisibleButtons: maxVisibleButtons,
      alignment: alignment,
      padding: padding,
      reduceAnimation: reduceAnimation,
      onOpened: () {
        if (hapticLevel.isFull) {
          HapticFeedback.selectionClick();
        }

        if (onOpened case final callback?) {
          callback();
        }
      },
      onClosed: onClosed,
      onMenuTap: () {
        if (hapticLevel.isFull) {
          HapticFeedback.selectionClick();
        }

        if (onMenuTap case final callback?) {
          callback();
        }
      },
    );
  }
}
