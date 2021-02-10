// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

ScrollController useScrollControllerForAnimation(
  AnimationController animationController,
  ScrollController scrollController,
) {
  scrollController.addListener(() {
    switch (scrollController.position.userScrollDirection) {
      // Scrolling up - forward the animation (value goes to 1)
      case ScrollDirection.forward:
        animationController.forward();
        break;
      // Scrolling down - reverse the animation (value goes to 0)
      case ScrollDirection.reverse:
        animationController.reverse();
        break;
      case ScrollDirection.idle:
        break;
    }
  });
  return scrollController;
}
