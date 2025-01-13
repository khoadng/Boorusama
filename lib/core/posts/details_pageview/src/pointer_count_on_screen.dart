// Flutter imports:
import 'package:flutter/material.dart';

class PointerCountOnScreen extends StatefulWidget {
  const PointerCountOnScreen({
    required this.enable,
    required this.onCountChanged,
    required this.child,
    super.key,
  });

  final Widget child;
  final bool enable;
  final void Function(int count) onCountChanged;

  @override
  State<PointerCountOnScreen> createState() => _PointerCountOnScreenState();
}

class _PointerCountOnScreenState extends State<PointerCountOnScreen> {
  final _pointersOnScreen = ValueNotifier<Set<int>>({});
  final _pointerCount = ValueNotifier<int>(0);
  late var enable = widget.enable;

  @override
  void initState() {
    super.initState();
    _pointersOnScreen.addListener(_onPointerChanged);
    _pointerCount.addListener(_onPointerCountChanged);
  }

  @override
  void didUpdateWidget(covariant PointerCountOnScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.enable != oldWidget.enable) {
      setState(() {
        enable = widget.enable;
      });
    }
  }

  void _onPointerCountChanged() {
    widget.onCountChanged(_pointerCount.value);
  }

  void _onPointerChanged() {
    _pointerCount.value = _pointersOnScreen.value.length;
  }

  void _addPointer(int index) {
    _pointersOnScreen.value = {..._pointersOnScreen.value, index};
  }

  void _removePointer(int index) {
    _pointersOnScreen.value = {..._pointersOnScreen.value}..remove(index);
  }

  @override
  void dispose() {
    super.dispose();
    _pointersOnScreen.removeListener(_onPointerChanged);
    _pointerCount.removeListener(_onPointerCountChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enable ? (event) => _addPointer(event.pointer) : null,
      onPointerMove: enable ? (event) => _addPointer(event.pointer) : null,
      onPointerCancel: enable ? (event) => _removePointer(event.pointer) : null,
      onPointerUp: enable ? (event) => _removePointer(event.pointer) : null,
      child: widget.child,
    );
  }
}
