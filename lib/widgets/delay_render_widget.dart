// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

class DelayedRenderWidget extends StatefulWidget {
  const DelayedRenderWidget({
    super.key,
    required this.delay,
    required this.child,
    this.placeholder,
  });

  final Duration delay;
  final Widget? placeholder;
  final Widget child;

  @override
  State<DelayedRenderWidget> createState() => _DelayedRenderWidgetState();
}

class _DelayedRenderWidgetState extends State<DelayedRenderWidget> {
  late Timer? _timer;
  var _shouldRender = false;

  @override
  void initState() {
    super.initState();

    _timer = Timer(
      widget.delay,
      () {
        setState(() {
          _shouldRender = true;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _shouldRender
        ? widget.child
        : widget.placeholder ?? const SizedBox.shrink();
  }
}
