import 'package:material_ui/material_ui.dart';

RouteTransitionsBuilder kurumiParallaxSlideInTransitionBuilder(
  Widget enterWidget,
  Widget oldWidget,
) =>
    (context, animation, secondaryAnimation, child) => Stack(
      children: [
        SlideTransition(
          position:
              Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-1, 0),
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              ),
          child: oldWidget,
        ),
        SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              ),
          child: enterWidget,
        ),
      ],
    );

RouteTransitionsBuilder kurumiLeftToRightTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => SlideTransition(
      position:
          Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
          ),
      child: child,
    );

RouteTransitionsBuilder kurumiFadeTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeInSine,
          reverseCurve: Curves.easeOutSine,
        ),
      ),
      child: child,
    );
