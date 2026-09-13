import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class KurumiLinearProgressIndicator extends StatelessWidget {
  const KurumiLinearProgressIndicator({
    required this.value,
    super.key,
    this.lineHeight = 2,
    this.color = Colors.red,
    this.backgroundColor = const Color(0xFFB8C7CB),
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    this.trailing,
    this.animationDuration = const Duration(milliseconds: 500),
    this.curve = Curves.linear,
  }) : assert(value >= 0 && value <= 1);

  final double value;
  final double lineHeight;
  final Color color;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final Widget? trailing;
  final Duration animationDuration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final duration =
        KurumiTheme.maybeBehaviorOf(
          context,
        )?.effectiveDuration(animationDuration) ??
        animationDuration;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: curve,
      child: trailing,
      builder: (context, animatedValue, trailing) => Row(
        children: [
          Expanded(
            child: Padding(
              padding: padding,
              child: LinearProgressIndicator(
                value: animatedValue,
                minHeight: lineHeight,
                color: color,
                backgroundColor: backgroundColor,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
