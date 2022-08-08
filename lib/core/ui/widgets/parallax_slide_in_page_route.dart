// Flutter imports:
import 'package:flutter/material.dart';

RouteTransitionsBuilder parallaxSlideInTransitionBuilder(
  Widget enterWidget,
  Widget oldWidget,
) =>
    (context, animation, secondaryAnimation, child) => Stack(
          children: <Widget>[
            SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(-1, 0),
                ).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.fastOutSlowIn),
                ),
                child: oldWidget),
            SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                      parent: animation, curve: Curves.fastOutSlowIn),
                ),
                child: enterWidget),
          ],
        );

class ParallaxSlideInPageRoute extends PageRouteBuilder {
  ParallaxSlideInPageRoute({
    required this.enterWidget,
    required this.oldWidget,
    RouteSettings? settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 350),
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => enterWidget,
          transitionsBuilder:
              parallaxSlideInTransitionBuilder(enterWidget, oldWidget),
        );

  final Widget enterWidget;
  final Widget oldWidget;
}
