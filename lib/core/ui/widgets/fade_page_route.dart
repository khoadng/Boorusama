// Flutter imports:
import 'package:flutter/material.dart';

class FadeMaterialPageRoute<T> extends MaterialPageRoute<T> {
  FadeMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }
}
