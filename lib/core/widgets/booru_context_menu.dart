// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../settings/providers.dart';
import 'context_menu.dart';

class BooruContextMenu extends ConsumerWidget {
  const BooruContextMenu({
    super.key,
    required this.child,
    required this.menuItemsBuilder,
  });

  final Widget child;
  final List<Widget> Function(BuildContext context) menuItemsBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

    return AnchorContextMenu(
      viewPadding: const EdgeInsets.all(8),
      backdropBuilder: isMobilePlatform()
          ? null
          : (context) => Container(
              color: Colors.transparent,
            ),
      onShow: () {
        if (hapticLevel.hasHapticFeedback) {
          HapticFeedback.selectionClick();
        }
      },
      menuBuilder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            boxShadow: kElevationToShadow[4],
            border: Border.all(
              color: colorScheme.outlineVariant,
            ),
          ),
          constraints: const BoxConstraints(
            maxWidth: 200,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: menuItemsBuilder(context),
          ),
        );
      },
      childBuilder: (context) => AdaptiveContextMenuGestureTrigger(
        child: child,
      ),
    );
  }
}

class BooruContextMenuDivider extends StatelessWidget {
  const BooruContextMenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      endIndent: 12,
      indent: 12,
      height: 8,
    );
  }
}
