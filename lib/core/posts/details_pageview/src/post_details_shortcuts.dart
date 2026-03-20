// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../foundation/keyboard/keyboard.dart';
import 'post_details_page_view_controller.dart';
import '../keybinds.dart';

class PostDetailsShortcuts extends ConsumerWidget {
  const PostDetailsShortcuts({
    required this.controller,
    required this.isLargeScreen,
    required this.child,
    super.key,
  });

  final PostDetailsPageViewController controller;
  final bool isLargeScreen;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.keyboardShortcutsEnabled,
      builder: (context, shortcutsEnabled, _) => ShortcutScope(
        handlers: shortcutsEnabled
            ? {
                kPostDetailsNextPage: () => controller.nextPage(
                  duration: isLargeScreen ? Duration.zero : null,
                ),
                kPostDetailsPreviousPage: () => controller.previousPage(
                  duration: isLargeScreen ? Duration.zero : null,
                ),
                kPostDetailsToggleOverlay: () => controller.toggleOverlay(),
                kPostDetailsClose: () => Navigator.of(context).maybePop(),
              }
            : {},
        autofocus: true,
        child: child,
      ),
    );
  }
}
