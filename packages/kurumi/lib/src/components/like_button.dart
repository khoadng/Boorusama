import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

typedef KurumiLikeButtonBuilder = Widget Function(bool isLiked);
typedef KurumiLikeButtonTapCallback = Future<bool?> Function(bool isLiked);

class KurumiLikeButton extends StatefulWidget {
  const KurumiLikeButton({
    required this.isLiked,
    required this.builder,
    super.key,
    this.onTap,
    this.size = 30,
    this.padding,
    this.animationDuration = const Duration(milliseconds: 1000),
  });

  final bool isLiked;
  final KurumiLikeButtonBuilder builder;
  final KurumiLikeButtonTapCallback? onTap;
  final double size;
  final EdgeInsetsGeometry? padding;
  final Duration animationDuration;

  @override
  State<KurumiLikeButton> createState() => _KurumiLikeButtonState();
}

class _KurumiLikeButtonState extends State<KurumiLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late bool _isLiked;
  bool _handlingTap = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(KurumiLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.animationDuration;

    if (widget.isLiked != oldWidget.isLiked && widget.isLiked != _isLiked) {
      final animate = widget.isLiked;
      _isLiked = widget.isLiked;
      if (animate) _playAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_handlingTap || _controller.isAnimating) return;

    _handlingTap = true;
    try {
      final next =
          await (widget.onTap?.call(_isLiked) ??
              Future<bool?>.value(!_isLiked));
      if (!mounted || next == null || next == _isLiked) return;

      setState(() => _isLiked = next);
      if (next) _playAnimation();
    } finally {
      _handlingTap = false;
    }
  }

  void _playAnimation() {
    if (KurumiTheme.maybeBehaviorOf(context)?.reduceMotion ?? false) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    Widget result = SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final scale = switch (progress) {
            < 0.35 => 1 - (progress / 0.35) * 0.8,
            < 0.7 => 0.2 + ((progress - 0.35) / 0.35) * 1.05,
            _ => 1.25 - ((progress - 0.7) / 0.3) * 0.25,
          };

          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: -widget.size / 2,
                top: -widget.size / 2,
                child: CustomPaint(
                  size: Size.square(widget.size * 2),
                  painter: _LikeBurstPainter(progress),
                ),
              ),
              Transform.scale(scale: scale, child: child),
            ],
          );
        },
        child: SizedBox.expand(child: widget.builder(_isLiked)),
      ),
    );

    if (widget.padding case final padding?) {
      result = Padding(padding: padding, child: result);
    }

    return Semantics(
      button: true,
      toggled: _isLiked,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _handleTap,
        child: result,
      ),
    );
  }
}

class _LikeBurstPainter extends CustomPainter {
  const _LikeBurstPainter(this.progress);

  final double progress;

  static const _directions = <Offset>[
    Offset(0, -1),
    Offset(0.707, -0.707),
    Offset(1, 0),
    Offset(0.707, 0.707),
    Offset(0, 1),
    Offset(-0.707, 0.707),
    Offset(-1, 0),
    Offset(-0.707, -0.707),
  ];

  static const _colors = <Color>[
    Color(0xFFFFC107),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFFF44336),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0 || progress == 1) return;

    final center = size.center(Offset.zero);
    final ringProgress = (progress / 0.45).clamp(0.0, 1.0);
    if (ringProgress < 1) {
      final ringPaint = Paint()
        ..color = Color.lerp(
          _colors.last,
          _colors.first,
          ringProgress,
        )!.withValues(alpha: 1 - ringProgress)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.055;
      canvas.drawCircle(
        center,
        size.shortestSide * (0.08 + ringProgress * 0.24),
        ringPaint,
      );
    }

    final particleProgress = ((progress - 0.15) / 0.85).clamp(0.0, 1.0);
    if (particleProgress <= 0) return;

    for (var i = 0; i < _directions.length; i++) {
      final radius = size.shortestSide * (0.18 + particleProgress * 0.27);
      final position = center + _directions[i] * radius;
      final particlePaint = Paint()
        ..color = _colors[i % _colors.length].withValues(
          alpha: 1 - particleProgress,
        );
      canvas.drawCircle(
        position,
        size.shortestSide * 0.035 * (1 - particleProgress * 0.5),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_LikeBurstPainter oldDelegate) =>
      progress != oldDelegate.progress;
}
