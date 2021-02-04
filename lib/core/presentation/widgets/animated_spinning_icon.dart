// Flutter imports:
import 'package:flutter/material.dart';

class AnimatedSpinningIcon extends AnimatedWidget {
  AnimatedSpinningIcon({
    Key key,
    Animation<double> animation,
    @required this.icon,
    this.onPressed,
  }) : super(key: key, listenable: animation);

  final VoidCallback onPressed;
  final Widget icon;

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Transform.rotate(
      angle: animation.value,
      child: IconButton(icon: icon, onPressed: () => onPressed()),
    );
  }
}
