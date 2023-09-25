// Flutter imports:
import 'package:flutter/material.dart';

RouteTransitionsBuilder parallaxSlideInTransitionBuilder(
  Widget enterWidget,
  Widget oldWidget,
) =>
    (context, animation, secondaryAnimation, child) => Stack(
          children: [
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(-1, 0),
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.fastOutSlowIn,
                ),
              ),
              child: oldWidget,
            ),
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.fastOutSlowIn),
              ),
              child: enterWidget,
            ),
          ],
        );

RouteTransitionsBuilder leftToRightTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            ),
          ),
          child: child,
        );

RouteTransitionsBuilder fadeTransitionBuilder() =>
    (context, animation, secondaryAnimation, child) => FadeTransition(
          opacity: Tween<double>(
            begin: 0.0, // Start with a fully transparent page
            end: 1.0, // End with a fully opaque page
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
          ),
          child: child,
        );
