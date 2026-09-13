import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class KurumiPulseIndicator extends StatefulWidget {
  const KurumiPulseIndicator({
    super.key,
    this.color,
    this.size = 50,
    this.duration = const Duration(seconds: 1),
  });

  final Color? color;
  final double size;
  final Duration duration;

  @override
  State<KurumiPulseIndicator> createState() => _KurumiPulseIndicatorState();
}

class _KurumiPulseIndicatorState extends State<KurumiPulseIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final CurvedAnimation _animation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion =
        KurumiTheme.maybeBehaviorOf(context)?.reduceMotion ?? false;
    if (reduceMotion == _reduceMotion && _controller.isAnimating) return;

    _reduceMotion = reduceMotion;
    if (reduceMotion) {
      _controller
        ..stop()
        ..value = 0.5;
    } else {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(KurumiPulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
      if (!_reduceMotion) _controller.repeat();
    }
  }

  @override
  void dispose() {
    _animation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;

    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Opacity(
          opacity: 1 - _animation.value,
          child: Transform.scale(scale: _animation.value, child: child),
        ),
        child: SizedBox.square(
          dimension: widget.size,
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}
