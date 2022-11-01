// Flutter imports:
import 'package:flutter/material.dart';

class AnimatedSpinningIcon extends AnimatedWidget {
  const AnimatedSpinningIcon({
    super.key,
    required Animation<double> animation,
    required this.icon,
    this.onPressed,
  }) : super(listenable: animation);

  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;

    return Transform.rotate(
      angle: animation.value,
      child: IconButton(
        icon: icon,
        onPressed: () => onPressed?.call(),
      ),
    );
  }
}
