import 'package:material_ui/material_ui.dart';

/// A region of the screen, such as a sidebar or the content beside it, that
/// Tab goes through as a whole before moving on.
///
/// Arrows are unaffected. A plain [FocusTraversalGroup] brings its own policy,
/// which keeps a separate history of arrow moves, so reversing an arrow after
/// crossing panes can jump back to a stale control. The pane reuses the policy
/// around it unless given one.
class KurumiFocusPane extends StatelessWidget {
  const KurumiFocusPane({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => FocusTraversalGroup(
    policy: FocusTraversalGroup.maybeOf(context),
    child: child,
  );
}
