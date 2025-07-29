// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'post_details_page_view_controller.dart';

class PostDetailsShortcuts extends StatelessWidget {
  const PostDetailsShortcuts({
    required this.controller,
    required this.useVerticalLayout,
    required this.isLargeScreen,
    required this.child,
    super.key,
  });

  final PostDetailsPageViewController controller;
  final bool useVerticalLayout;
  final bool isLargeScreen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        SingleActivator(
          useVerticalLayout
              ? LogicalKeyboardKey.arrowDown
              : LogicalKeyboardKey.arrowRight,
        ): () {
          controller.nextPage(
            duration: isLargeScreen ? Duration.zero : null,
          );
        },
        SingleActivator(
          useVerticalLayout
              ? LogicalKeyboardKey.arrowUp
              : LogicalKeyboardKey.arrowLeft,
        ): () {
          controller.previousPage(
            duration: isLargeScreen ? Duration.zero : null,
          );
        },
        const SingleActivator(LogicalKeyboardKey.keyO): () =>
            controller.toggleOverlay(),
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}
