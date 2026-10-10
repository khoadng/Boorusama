// Flutter imports:
import 'package:flutter/services.dart';

// Package imports:
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import 'post_details_page_view_controller.dart';

class PostDetailsShortcuts extends StatefulWidget {
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
  State<PostDetailsShortcuts> createState() => _PostDetailsShortcutsState();
}

class _PostDetailsShortcutsState extends State<PostDetailsShortcuts> {
  final _pageNode = FocusNode(debugLabel: 'PostDetailsPage');

  @override
  void dispose() {
    _pageNode.dispose();
    super.dispose();
  }

  // Arrows only act on the page while the page itself holds focus. Once a
  // control is focused they fall through to normal focus traversal, so
  // remote and keyboard users can move between controls.
  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    if (!node.hasPrimaryFocus ||
        !widget.controller.keyboardShortcutsEnabled.value) {
      return KeyEventResult.ignored;
    }

    final duration = widget.isLargeScreen ? Duration.zero : null;
    final vertical = widget.useVerticalLayout;

    return switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown when vertical => _handled(
        () => widget.controller.nextPage(duration: duration),
      ),
      LogicalKeyboardKey.arrowRight when !vertical => _handled(
        () => widget.controller.nextPage(duration: duration),
      ),
      LogicalKeyboardKey.arrowUp when vertical => _handled(
        () => widget.controller.previousPage(duration: duration),
      ),
      LogicalKeyboardKey.arrowLeft when !vertical => _handled(
        () => widget.controller.previousPage(duration: duration),
      ),
      LogicalKeyboardKey.arrowUp => _enterControls(TraversalDirection.up),
      LogicalKeyboardKey.arrowDown => _enterControls(TraversalDirection.down),
      LogicalKeyboardKey.arrowLeft => _enterControls(TraversalDirection.left),
      LogicalKeyboardKey.arrowRight => _enterControls(
        TraversalDirection.right,
      ),
      _ => KeyEventResult.ignored,
    };
  }

  KeyEventResult _handled(void Function() action) {
    action();
    return KeyEventResult.handled;
  }

  // The page covers the whole screen, so regular directional traversal finds
  // nothing beyond its edges. Jump to the outermost control in view instead,
  // rather than one scrolled far down a side panel.
  KeyEventResult _enterControls(TraversalDirection direction) {
    final target = outermostFocusTowards(
      _pageNode.traversalDescendants.where(
        (node) => node.canRequestFocus && !visibleFocusRect(node).isEmpty,
      ),
      direction,
    );
    if (target == null) return KeyEventResult.ignored;

    target.requestFocus();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.controller.keyboardShortcutsEnabled,
      builder: (context, shortcutsEnabled, _) => CallbackShortcuts(
        bindings: shortcutsEnabled
            ? {
                const SingleActivator(LogicalKeyboardKey.keyO): () =>
                    widget.controller.toggleOverlay(),
                const SingleActivator(LogicalKeyboardKey.escape): () =>
                    Navigator.of(context).maybePop(),
              }
            : {},
        child: Actions(
          actions: {
            DirectionalFocusIntent: _ReturnToPageAction(_pageNode),
          },
          child: Focus(
            focusNode: _pageNode,
            autofocus: true,
            skipTraversal: true,
            onKeyEvent: _handleKey,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Moves focus between controls as usual, but hands it back to the page when
/// no control lies in that direction, so arrows never dead-end on a control.
class _ReturnToPageAction extends DirectionalFocusAction {
  _ReturnToPageAction(this.pageNode);

  final FocusNode pageNode;

  @override
  void invoke(DirectionalFocusIntent intent) {
    final focused = primaryFocus;
    if (focused == null || focused == pageNode) return;
    if (!focused.focusInDirection(intent.direction)) {
      pageNode.requestFocus();
    }
  }
}

/// The node whose visible part sits furthest towards [direction], with ties
/// broken by reading order, so pressing up lands on the top-left control.
FocusNode? outermostFocusTowards(
  Iterable<FocusNode> nodes,
  TraversalDirection direction,
) {
  final edge = switch (direction) {
    TraversalDirection.up => (Rect r) => r.top,
    TraversalDirection.down => (Rect r) => -r.bottom,
    TraversalDirection.left => (Rect r) => r.left,
    TraversalDirection.right => (Rect r) => -r.right,
  };
  final crossAxis = switch (direction) {
    TraversalDirection.up || TraversalDirection.down => (Rect r) => r.left,
    TraversalDirection.left || TraversalDirection.right => (Rect r) => r.top,
  };

  int compare(FocusNode a, FocusNode b) {
    final (rectA, rectB) = (visibleFocusRect(a), visibleFocusRect(b));
    return switch (edge(rectA).compareTo(edge(rectB))) {
      0 => crossAxis(rectA).compareTo(crossAxis(rectB)),
      final order => order,
    };
  }

  return nodes.fold<FocusNode?>(
    null,
    (best, node) => switch (best) {
      final best? when compare(best, node) <= 0 => best,
      _ => node,
    },
  );
}
