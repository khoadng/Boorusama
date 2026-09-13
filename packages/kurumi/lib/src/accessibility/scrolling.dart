import 'package:material_ui/material_ui.dart';

class KurumiNoOverscrollBehavior extends ScrollBehavior {
  const KurumiNoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

extension KurumiScrollControllerAccessibilityAware on ScrollController {
  Future<void> animateToWithAccessibility(
    double offset, {
    required Duration duration,
    required Curve curve,
    required bool reduceAnimations,
  }) async {
    if (reduceAnimations) {
      return jumpTo(offset);
    } else {
      return animateTo(
        offset,
        duration: duration,
        curve: curve,
      );
    }
  }
}
