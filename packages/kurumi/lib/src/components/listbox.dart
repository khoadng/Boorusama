import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

/// Highlights one row of a list while focus stays somewhere else, such as in
/// the text field the list suggests for: arrows move the highlight, Enter
/// picks the row and Escape drops the highlight. Typing goes on in the field
/// the whole time, as in a browser's address bar.
///
/// The list registers its rows through [KurumiListbox]; [KurumiListboxKeys]
/// feeds it the keys pressed in the field.
class KurumiListboxController extends ChangeNotifier {
  int? _active;
  Object? _owner;
  var _count = 0;
  var _reversed = false;
  ValueChanged<int>? _onPick;

  /// The highlighted row, or null while the field keeps the keys.
  int? get active => _active;

  // A reversed list grows upwards from the field, so up moves into it
  // instead of down.
  void _attach(
    Object owner, {
    required int count,
    required bool reversed,
    required ValueChanged<int> onPick,
  }) {
    _owner = owner;
    _count = count;
    _reversed = reversed;
    _onPick = onPick;
    if (_active case final active? when active >= count) _active = null;
  }

  void _detach(Object owner) {
    if (_owner != owner) return;
    _owner = null;
    _count = 0;
    _onPick = null;
    _active = null;
  }

  /// Moves the highlight one row [direction], leaving the list back into the
  /// field past its first row. False when the list has nothing to say about
  /// [direction], so the key can do its usual job.
  bool move(TraversalDirection direction) {
    final forward = switch (direction) {
      TraversalDirection.down => !_reversed,
      TraversalDirection.up => _reversed,
      TraversalDirection.left || TraversalDirection.right => null,
    };
    if (forward == null || _count == 0) return false;

    final next = switch ((_active, forward)) {
      (null, true) => 0,
      (null, false) => -1,
      (final active?, true) => (active + 1).clamp(0, _count - 1),
      (final active?, false) => active - 1,
    };
    if (next == -1 && _active == null) return false;
    _setActive(next < 0 ? null : next);
    return true;
  }

  /// Picks the highlighted row. False when nothing is highlighted.
  bool pick() {
    final (active, onPick) = (_active, _onPick);
    if (active == null || onPick == null) return false;
    _setActive(null);
    onPick(active);
    return true;
  }

  /// Drops the highlight. False when nothing was highlighted.
  bool clear() {
    if (_active == null) return false;
    _setActive(null);
    return true;
  }

  void _setActive(int? value) {
    if (_active == value) return;
    _active = value;
    notifyListeners();
  }
}

/// Registers a list of [count] rows with [controller] while it's shown, so
/// keys only reach rows that are there.
class KurumiListbox extends StatefulWidget {
  const KurumiListbox({
    required this.controller,
    required this.count,
    required this.onPick,
    required this.child,
    super.key,
    this.reversed = false,
  });

  final KurumiListboxController controller;
  final int count;
  final bool reversed;
  final ValueChanged<int> onPick;
  final Widget child;

  @override
  State<KurumiListbox> createState() => _KurumiListboxState();
}

class _KurumiListboxState extends State<KurumiListbox> {
  @override
  void didUpdateWidget(KurumiListbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._detach(this);
    }
  }

  @override
  void dispose() {
    widget.controller._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.controller._attach(
      this,
      count: widget.count,
      reversed: widget.reversed,
      onPick: widget.onPick,
    );
    return widget.child;
  }
}

/// Sends arrows, Enter and Escape pressed in [child], typically a text field,
/// to [controller] first.
class KurumiListboxKeys extends StatelessWidget {
  const KurumiListboxKeys({
    required this.controller,
    required this.child,
    super.key,
  });

  final KurumiListboxController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    onKeyEvent: (node, event) {
      if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
        return KeyEventResult.ignored;
      }
      final handled = switch (event.logicalKey) {
        LogicalKeyboardKey.arrowDown => controller.move(
          TraversalDirection.down,
        ),
        LogicalKeyboardKey.arrowUp => controller.move(TraversalDirection.up),
        LogicalKeyboardKey.enter ||
        LogicalKeyboardKey.numpadEnter ||
        LogicalKeyboardKey.select => event is KeyDownEvent && controller.pick(),
        LogicalKeyboardKey.escape => controller.clear(),
        _ => false,
      };
      return handled ? KeyEventResult.handled : KeyEventResult.ignored;
    },
    child: child,
  );
}

/// A row of a [KurumiListboxController] list, drawn highlighted while
/// [active] and scrolled into view as it becomes so.
class KurumiListboxItem extends StatefulWidget {
  const KurumiListboxItem({
    required this.active,
    required this.child,
    super.key,
  });

  final bool active;
  final Widget child;

  @override
  State<KurumiListboxItem> createState() => _KurumiListboxItemState();
}

class _KurumiListboxItemState extends State<KurumiListboxItem> {
  @override
  void initState() {
    super.initState();
    if (widget.active) _reveal();
  }

  @override
  void didUpdateWidget(KurumiListboxItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active) _reveal();
  }

  void _reveal() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) Scrollable.ensureVisible(context);
  });

  @override
  Widget build(BuildContext context) => Semantics(
    selected: widget.active,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: widget.active
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)
            : null,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: widget.child,
    ),
  );
}
