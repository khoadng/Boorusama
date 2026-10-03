import 'dart:async';

import 'package:material_ui/material_ui.dart';

/// Arrow-key focus movement for D-pad and keyboard users, installed once at
/// the app root in place of the default [DirectionalFocusAction].
///
/// On top of the default it:
/// * crosses focus scope boundaries inside the top route, such as a nested
///   [Navigator] next to a sidebar, when nothing lies in that direction
///   within the current scope;
/// * skips controls hidden by a scroll view the user is not inside, such as
///   list tiles scrolled under a header, when a visible control lies in that
///   direction;
/// * scrolls the newly focused control into view when it ends up off-screen,
///   which the default skips when moving up onto a control below the
///   viewport.
class KurumiDirectionalFocusAction extends DirectionalFocusAction {
  @override
  void invoke(DirectionalFocusIntent intent) {
    final focused = primaryFocus;
    if (focused == null) return;

    // The default traversal scrolls its pick into view right away, so what
    // was hidden has to be noted before moving.
    final hidden = {
      for (final node in _candidates(except: focused))
        if (visibleFocusRect(node).isEmpty) node,
    };

    if (!focused.focusInDirection(intent.direction)) {
      nearestFocusInDirection(
        _candidates(except: focused),
        from: focused.rect,
        direction: intent.direction,
      )?.requestFocus();
    }

    // Focus changes apply in a microtask, so check where focus landed once
    // they have, before revealing scrolls anything.
    scheduleMicrotask(
      () => _settle(
        from: focused,
        direction: intent.direction,
        hidden: hidden,
      ),
    );
  }

  void _settle({
    required FocusNode from,
    required TraversalDirection direction,
    required Set<FocusNode> hidden,
  }) {
    final landed = primaryFocus;
    final visible = switch (landed) {
      final landed?
          when hidden.contains(landed) && !_isInListOf(landed, from) =>
        nearestFocusInDirection(
          _candidates(except: from).where((node) => !hidden.contains(node)),
          from: from.rect,
          direction: direction,
        ),
      _ => null,
    };

    if (visible == null) return _revealFocus();
    visible.requestFocus();
    scheduleMicrotask(_revealFocus);
  }

  // Moving within a list onto a control scrolled out of view is expected, as
  // revealing scrolls it in; arriving there from outside the list is not.
  static bool _isInListOf(FocusNode node, FocusNode from) {
    final list = switch (node.context) {
      final context? => Scrollable.maybeOf(context),
      null => null,
    };
    final fromContext = from.context;
    if (list == null || fromContext == null) return false;

    var inside = false;
    fromContext.visitAncestorElements((element) {
      inside = element == list.context;
      return !inside;
    });
    return inside;
  }

  // Scopes of routes that are not on top skip traversal, which keeps
  // candidates inside the top route.
  Iterable<FocusNode> _candidates({required FocusNode except}) =>
      FocusManager.instance.rootScope.traversalDescendants.where(
        (node) =>
            node != except &&
            node is! FocusScopeNode &&
            !node.rect.isEmpty &&
            !node.ancestors.whereType<FocusScopeNode>().any(
              (scope) => scope.skipTraversal,
            ),
      );

  void _revealFocus() {
    final node = primaryFocus;
    final context = node?.context;
    if (node == null || context == null) return;

    final screen = Offset.zero & MediaQuery.sizeOf(context);
    final rect = node.rect;
    final alignment = switch (rect) {
      _ when rect.top < screen.top || rect.left < screen.left =>
        ScrollPositionAlignmentPolicy.keepVisibleAtStart,
      _ when rect.bottom > screen.bottom || rect.right > screen.right =>
        ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      _ => null,
    };
    if (alignment == null) return;

    Scrollable.ensureVisible(context, alignmentPolicy: alignment);
  }
}

/// [node]'s rect clipped to every scroll view around it: what of the control
/// is actually on screen.
Rect visibleFocusRect(FocusNode node) {
  var rect = node.rect;
  final context = node.context;
  if (context == null) return Rect.zero;

  for (
    var scrollable = Scrollable.maybeOf(context);
    scrollable != null;
    scrollable = Scrollable.maybeOf(scrollable.context)
  ) {
    if (scrollable.context.findRenderObject() case final RenderBox box
        when box.hasSize) {
      rect = rect.intersect(box.localToGlobal(Offset.zero) & box.size);
    }
  }
  return rect;
}

/// The node closest to [from] among those past its edge in [direction] that
/// overlap it on the cross axis.
FocusNode? nearestFocusInDirection(
  Iterable<FocusNode> nodes, {
  required Rect from,
  required TraversalDirection direction,
}) {
  final ahead = nodes.where(
    (node) => switch (direction) {
      TraversalDirection.up => node.rect.center.dy <= from.top,
      TraversalDirection.down => node.rect.center.dy >= from.bottom,
      TraversalDirection.left => node.rect.center.dx <= from.left,
      TraversalDirection.right => node.rect.center.dx >= from.right,
    },
  );

  double gap(Rect rect) => switch (direction) {
    TraversalDirection.up => from.top - rect.bottom,
    TraversalDirection.down => rect.top - from.bottom,
    TraversalDirection.left => from.left - rect.right,
    TraversalDirection.right => rect.left - from.right,
  }.clamp(0, double.infinity);

  double crossDistance(Rect rect) => switch (direction) {
    TraversalDirection.up ||
    TraversalDirection.down => (rect.center.dx - from.center.dx).abs(),
    TraversalDirection.left ||
    TraversalDirection.right => (rect.center.dy - from.center.dy).abs(),
  };

  bool overlapsCrossAxis(Rect rect) => switch (direction) {
    TraversalDirection.up ||
    TraversalDirection.down => rect.left < from.right && rect.right > from.left,
    TraversalDirection.left || TraversalDirection.right =>
      rect.top < from.bottom && rect.bottom > from.top,
  };

  // Only controls level with the current one count, so reaching the end of a
  // list does not jump into an unrelated pane.
  final pool = ahead.where((node) => overlapsCrossAxis(node.rect));

  int compare(FocusNode a, FocusNode b) =>
      switch (gap(a.rect).compareTo(gap(b.rect))) {
        0 => crossDistance(a.rect).compareTo(crossDistance(b.rect)),
        final order => order,
      };

  return pool.fold<FocusNode?>(
    null,
    (best, node) => switch (best) {
      final best? when compare(best, node) <= 0 => best,
      _ => node,
    },
  );
}

/// Lets up and down leave a single-line text field, where they would only
/// move the caret to the start or end. Multi-line fields keep their default.
///
/// Register it under [ExtendSelectionVerticallyToAdjacentLineIntent]; it is
/// typed on the parent intent to match the text field action it overrides.
class KurumiLeaveSingleLineFieldAction
    extends ContextAction<DirectionalCaretMovementIntent> {
  // Outside a text field there is no default to override; staying disabled
  // lets the arrow fall through to directional focus.
  @override
  bool isEnabled(
    DirectionalCaretMovementIntent intent, [
    BuildContext? context,
  ]) => callingAction?.isEnabled(intent) ?? false;

  @override
  Object? invoke(
    DirectionalCaretMovementIntent intent, [
    BuildContext? context,
  ]) {
    final focusContext = primaryFocus?.context;
    final field = focusContext?.findAncestorWidgetOfExactType<EditableText>();

    return switch ((field, focusContext)) {
      (EditableText(maxLines: 1), final focusContext?)
          when intent.collapseSelection =>
        Actions.maybeInvoke(
          focusContext,
          DirectionalFocusIntent(
            intent.forward ? TraversalDirection.down : TraversalDirection.up,
            ignoreTextFields: false,
          ),
        ),
      _ => callingAction?.invoke(intent),
    };
  }
}
