// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/platform.dart';
import 'hover_aware_container.dart';

class BooruPopupMenuButton extends ConsumerWidget {
  const BooruPopupMenuButton({
    required this.items,
    this.iconColor,
    super.key,
    this.maxWidth,
  });

  final List<Widget> items;
  final Color? iconColor;
  final double? maxWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final icon = Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(
        Icons.more_vert,
        color: iconColor,
      ),
    );

    final isDesktop = isDesktopPlatform();

    return AnchorPopover(
      arrowShape: const NoArrow(),
      placement: Placement.bottom,
      backdropBuilder: switch (isDesktop) {
        true => null,
        false => (context) => Container(
          color: Colors.black.withValues(alpha: 0.75),
        ),
      },
      triggerMode: const AnchorTriggerMode.tap(consumeOutsideTap: true),
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
      viewPadding: const EdgeInsets.all(8),
      backgroundColor: isDesktop ? null : colorScheme.surface,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        constraints: BoxConstraints(
          maxWidth: min(MediaQuery.widthOf(context), maxWidth ?? 200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: items,
        ),
      ),
      child: isDesktop
          ? HoverAwareContainer(
              borderRadius: BorderRadius.circular(12),
              child: icon,
            )
          : Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: icon,
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
