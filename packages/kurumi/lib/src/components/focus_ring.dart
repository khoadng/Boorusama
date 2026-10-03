import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import 'cross_scope_focus.dart';

/// Outlines the focused control while the user navigates with a keyboard or
/// D-pad, so focus stays easy to spot from across a room. Installed once near
/// the app root; touch and mouse users never see it.
///
/// Controls that arrows skip, such as a page-wide key handler, get no ring.
/// A mouse click keeps Flutter in keyboard highlight mode, so the ring also
/// hides on any pointer press and returns with the next key press.
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
  var _pointerActive = false;

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
    if (event is! PointerDownEvent || _pointerActive) return;
    _pointerActive = true;
    _scheduleSync();
  }

  bool _onKey(KeyEvent event) {
    if (event is KeyDownEvent && _pointerActive) {
      _pointerActive = false;
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
          when !_pointerActive &&
              node is! FocusScopeNode &&
              !node.skipTraversal &&
              (node.context?.mounted ?? false) =>
        switch (visibleFocusRect(node)) {
          final rect when rect.isEmpty => null,
          final rect => rect.shift(-origin),
        },
      _ => null,
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
