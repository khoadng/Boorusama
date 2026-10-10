import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Claims the system back button and Escape while [enabled], so they close
/// something transient like a menu instead of reaching the route.
///
/// A blocking [PopScope] would also notify every other [PopScope] on the
/// route, letting them pop the page or show their own dialogs.
class KurumiBackHandler extends StatelessWidget {
  const KurumiBackHandler({
    required this.enabled,
    required this.onBack,
    required this.child,
    super.key,
  });

  final bool enabled;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => KurumiDismissible(
    enabled: enabled,
    onDismiss: onBack,
    child: switch (Router.maybeOf(context)?.backButtonDispatcher) {
      null => PopScope(
        canPop: !enabled,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && enabled) onBack();
        },
        child: child,
      ),
      _ => BackButtonListener(
        onBackButtonPressed: () async {
          if (!enabled) return false;
          onBack();
          return true;
        },
        child: child,
      ),
    },
  );
}

/// Closes the layer [child] belongs to when Escape is pressed while focus is
/// inside it. The innermost enabled layer wins, so each press closes one
/// layer: a menu before the dialog it opened from, the dialog before the page.
///
/// A layer that is closed lets Escape through to the ones around it, and
/// once none takes it, Escape reaches the app's [DismissIntent], which
/// dialogs, sheets and drawers that close on a barrier tap answer to.
class KurumiDismissible extends StatefulWidget {
  const KurumiDismissible({
    required VoidCallback this.onDismiss,
    required this.child,
    super.key,
    this.enabled = true,
  });

  /// Closes the route [child] is in, like a barrier tap would. The route's
  /// [PopScope]s still get to keep it open, such as to save a draft first.
  const KurumiDismissible.route({
    required this.child,
    super.key,
    this.enabled = true,
  }) : onDismiss = null;

  final VoidCallback? onDismiss;
  final bool enabled;
  final Widget child;

  /// Closes the innermost open layer around [node], as Escape would with
  /// [node] focused. For a popover that lives outside the control it belongs
  /// to. False when no layer around [node] is open.
  static bool dismissFrom(FocusNode node) => [node, ...node.ancestors]
      .map((node) => _KurumiDismissibleState._owners[node])
      .nonNulls
      .any((layer) => layer._dismiss());

  @override
  State<KurumiDismissible> createState() => _KurumiDismissibleState();
}

// Listens on the focus path rather than through [Actions]: every route
// answers [DismissIntent] itself, even when it can't be dismissed, which would
// hide the layers around a nested navigator.
class _KurumiDismissibleState extends State<KurumiDismissible> {
  static final _owners = Expando<_KurumiDismissibleState>();

  final _node = FocusNode(
    debugLabel: 'KurumiDismissible',
    canRequestFocus: false,
    skipTraversal: true,
  );

  @override
  void initState() {
    super.initState();
    _owners[_node] = this;
  }

  @override
  void dispose() {
    _node.dispose();
    super.dispose();
  }

  bool _dismiss() {
    if (!widget.enabled) return false;
    switch (widget.onDismiss) {
      case final dismiss?:
        dismiss();
      case null:
        Navigator.maybePop(context);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _node,
    includeSemantics: false,
    onKeyEvent: (_, event) => switch (event) {
      KeyDownEvent(logicalKey: LogicalKeyboardKey.escape) when _dismiss() =>
        KeyEventResult.handled,
      _ => KeyEventResult.ignored,
    },
    child: widget.child,
  );
}
