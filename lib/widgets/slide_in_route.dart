// Flutter imports:
import 'package:flutter/cupertino.dart';

class SlideInRoute extends PageRouteBuilder {
  SlideInRoute({
    required super.pageBuilder,
    super.transitionDuration = const Duration(milliseconds: 200),
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final tween = Tween(begin: const Offset(1, 0), end: Offset.zero);

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
