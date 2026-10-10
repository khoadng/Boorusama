import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'cross_scope_focus.dart';

/// Outlines the focused control while the user navigates with a keyboard or
/// D-pad, so focus stays easy to spot from across a room. Installed once near
/// the app root; touch and mouse users never see it.
///
/// Controls that arrows skip, such as a page-wide key handler, get no ring,
/// and neither do text fields that draw their own focused border.
/// Desktop starts in keyboard highlight mode and a mouse click keeps it there,
/// so the ring waits for a key press and hides again on any pointer press. A
/// mouse press also focuses the control under it, so the next key press
/// continues from there.
class KurumiFocusRing extends StatefulWidget {
  const KurumiFocusRing({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<KurumiFocusRing> createState() => _KurumiFocusRingState();
}

class _KurumiFocusRingState extends State<KurumiFocusRing> {
  Rect? _ring;
  var _keyboardActive = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance
      ..addListener(_scheduleSync)
      ..addHighlightModeListener(_onHighlightModeChanged);
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onPointer);
    HardwareKeyboard.instance.addHandler(_onKey);
    _syncAfterFrame();
  }

  @override
  void dispose() {
    FocusManager.instance
      ..removeListener(_scheduleSync)
      ..removeHighlightModeListener(_onHighlightModeChanged);
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onPointer);
    HardwareKeyboard.instance.removeHandler(_onKey);
    super.dispose();
  }

  void _onPointer(PointerEvent event) {
    if (event is! PointerDownEvent) return;
    if (event.kind == PointerDeviceKind.mouse) _focusControlAt(event);
    if (!_keyboardActive) return;
    _keyboardActive = false;
    _scheduleSync();
  }

  // Flutter buttons don't take focus when clicked, which would leave the
  // next key press continuing from wherever focus was before. Like a
  // browser, a mouse press focuses the innermost control under it. Touch is
  // left alone so tapping a button doesn't close the soft keyboard.
  void _focusControlAt(PointerDownEvent event) {
    final hit = HitTestResult();
    WidgetsBinding.instance.hitTestInView(hit, event.position, event.viewId);
    final controls = <RenderObject, FocusNode>{};
    for (final node in FocusManager.instance.rootScope.descendants) {
      if (node is FocusScopeNode || !node.canRequestFocus) continue;
      final box = switch (node.context) {
        final context? when context.mounted => context.findRenderObject(),
        _ => null,
      };
      // Nested nodes can share a render object. Descendants list inner nodes
      // before their parents, so the inner one wins.
      if (box != null) controls.putIfAbsent(box, () => node);
    }

    final control = hit.path
        .map((entry) => controls[entry.target])
        .nonNulls
        .firstOrNull;
    // A control arrows pass over, such as a text field behind a bar, manages
    // its own focus.
    if (control case final control?
        when !control.skipTraversal && !control.hasFocus) {
      control.requestFocus();
    }
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent && !_keyboardActive) {
      _keyboardActive = true;
      _scheduleSync();
    }
    return false;
  }

  void _onHighlightModeChanged(FocusHighlightMode _) => _scheduleSync();

  void _scheduleSync() => WidgetsBinding.instance.ensureVisualUpdate();

  // Layout is final once a frame ends, so the ring is measured then. Focused
  // controls move while scrolling, hence a check after every frame; it only
  // asks for another frame when the ring actually moved.
  void _syncAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final ring = _measureRing();
      if (ring != _ring) setState(() => _ring = ring);
      _syncAfterFrame();
    });
  }

  Rect? _measureRing() {
    final node = FocusManager.instance.primaryFocus;
    final origin = switch (context.findRenderObject()) {
      final RenderBox box when box.hasSize => box.localToGlobal(Offset.zero),
      _ => null,
    };
    return switch ((FocusManager.instance.highlightMode, node, origin)) {
      (FocusHighlightMode.traditional, final node?, final origin?)
          when _keyboardActive &&
              node is! FocusScopeNode &&
              !node.skipTraversal &&
              !_drawsOwnFocusBorder(node) &&
              (node.context?.mounted ?? false) =>
        switch (visibleFocusRect(node)) {
          final rect when rect.isEmpty => null,
          final rect => rect.shift(-origin),
        },
      _ => null,
    };
  }

  // Text fields get the theme's decoration merged in before it reaches
  // their decorator, so what it holds is what gets drawn.
  static bool _drawsOwnFocusBorder(FocusNode node) {
    final context = node.context;
    if (context?.findAncestorWidgetOfExactType<EditableText>() == null) {
      return false;
    }
    final decoration = context
        ?.findAncestorWidgetOfExactType<InputDecorator>()
        ?.decoration;
    return switch (decoration?.focusedBorder ?? decoration?.border) {
      null => decoration != null && decoration.isCollapsed != true,
      final border =>
        border.borderSide.style != BorderStyle.none &&
            border.borderSide.width > 0,
    };
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      widget.child,
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _RingPainter(
              ring: _ring,
              color: Theme.of(context).colorScheme.primary,
              pixelRatio: MediaQuery.devicePixelRatioOf(context),
            ),
          ),
        ),
      ),
    ],
  );
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.ring,
    required this.color,
    required this.pixelRatio,
  });

  final Rect? ring;
  final Color color;
  final double pixelRatio;

  static const _gap = 2.0;
  static const _thickness = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (ring case final ring?) {
      // Whole device pixels keep the band solid instead of blurred at its
      // edges, and controls touching the screen edge keep it on screen.
      final outer = _snap(
        ring.inflate(_gap + _thickness),
      ).intersect(Offset.zero & size);
      canvas.drawDRRect(
        RRect.fromRectAndRadius(outer, const Radius.circular(10)),
        RRect.fromRectAndRadius(
          outer.deflate(_thickness),
          const Radius.circular(10 - _thickness),
        ),
        Paint()..color = color,
      );
    }
  }

  Rect _snap(Rect rect) => Rect.fromLTRB(
    (rect.left * pixelRatio).roundToDouble() / pixelRatio,
    (rect.top * pixelRatio).roundToDouble() / pixelRatio,
    (rect.right * pixelRatio).roundToDouble() / pixelRatio,
    (rect.bottom * pixelRatio).roundToDouble() / pixelRatio,
  );

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.ring != ring ||
      oldDelegate.color != color ||
      oldDelegate.pixelRatio != pixelRatio;
}
