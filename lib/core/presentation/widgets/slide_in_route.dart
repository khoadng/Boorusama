// Flutter imports:
import 'package:flutter/cupertino.dart';

class SlideInRoute extends PageRouteBuilder {
  SlideInRoute({
    required RoutePageBuilder pageBuilder,
    Duration transitionDuration = const Duration(milliseconds: 200),
  }) : super(
          pageBuilder: pageBuilder,
          transitionDuration: transitionDuration,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    var tween = Tween(begin: const Offset(1, 0), end: Offset.zero);

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}
