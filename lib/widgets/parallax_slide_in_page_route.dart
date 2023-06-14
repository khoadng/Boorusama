// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/widgets.dart';

class ParallaxSlideInPageRoute extends PageRouteBuilder {
  ParallaxSlideInPageRoute({
    required this.enterWidget,
    required this.oldWidget,
    super.settings,
  }) : super(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (context, animation, secondaryAnimation) => enterWidget,
          transitionsBuilder:
              parallaxSlideInTransitionBuilder(enterWidget, oldWidget),
        );

  final Widget enterWidget;
  final Widget oldWidget;
}
