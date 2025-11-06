// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../settings/providers.dart';

class BooruPopupMenuButton extends ConsumerStatefulWidget {
  const BooruPopupMenuButton({
    required this.items,
    this.iconColor,
    this.iconBackgroundColor,
    super.key,
    this.maxWidth,
  });

  final List<Widget> items;
  final Color? iconColor;
  final double? maxWidth;
  final Color? iconBackgroundColor;

  @override
  ConsumerState<BooruPopupMenuButton> createState() =>
      _BooruPopupMenuButtonState();
}

class _BooruPopupMenuButtonState extends ConsumerState<BooruPopupMenuButton> {
  final _controller = AnchorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

    final isDesktop = isDesktopPlatform();

    return AnchorPopover(
      controller: _controller,
      arrowShape: const NoArrow(),
      placement: Placement.bottom,
      backdropBuilder: (context) => GestureDetector(
        onTap: () {
          _controller.hide();
        },
        child: Container(
          color: isDesktop
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.75),
        ),
      ),
      triggerMode: const AnchorTriggerMode.manual(),
      border: BorderSide(
        color: colorScheme.outlineVariant,
        width: 0.5,
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      viewPadding: const EdgeInsets.all(4),
      backgroundColor: isDesktop ? null : colorScheme.surface,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        constraints: BoxConstraints(
          maxWidth: min(MediaQuery.widthOf(context), widget.maxWidth ?? 200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.items,
        ),
      ),
      child: Material(
        color: widget.iconBackgroundColor ?? Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            if (hapticLevel.isFull) {
              HapticFeedback.selectionClick();
            }
            _controller.toggle();
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.more_vert,
              color: widget.iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

class BooruPopupMenuItem extends StatelessWidget {
  const BooruPopupMenuItem({
    required this.title,
    required this.onTap,
    this.icon,
    super.key,
  });

  final Widget title;
  final Widget? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = AnchorData.maybeOf(context)?.controller;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          controller?.hide();
          onTap();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: Row(
            children: [
              if (icon case final icon?)
                Theme(
                  data: Theme.of(context).copyWith(
                    iconTheme: IconThemeData(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: icon,
                  ),
                ),
              Flexible(child: title),
            ],
          ),
        ),
      ),
    );
  }
}
