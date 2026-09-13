import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class KurumiRefreshIndicator extends StatelessWidget {
  const KurumiRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
    this.displacement = 40.0,
    this.edgeOffset = 0.0,
    this.color,
    this.backgroundColor,
    this.notificationPredicate,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeWidth,
    this.triggerMode,
  });

  final Widget child;
  final RefreshCallback onRefresh;
  final double displacement;
  final double edgeOffset;
  final Color? color;
  final Color? backgroundColor;
  final ScrollNotificationPredicate? notificationPredicate;
  final String? semanticsLabel;
  final String? semanticsValue;
  final double? strokeWidth;
  final RefreshIndicatorTriggerMode? triggerMode;

  @override
  Widget build(BuildContext context) {
    final refreshFeedback = KurumiTheme.maybeBehaviorOf(
      context,
    )?.refreshFeedback;

    return RefreshIndicator(
      onRefresh: () {
        refreshFeedback?.call();
        return onRefresh();
      },
      displacement: displacement,
      edgeOffset: edgeOffset,
      color: color,
      backgroundColor: backgroundColor,
      notificationPredicate:
          notificationPredicate ?? defaultScrollNotificationPredicate,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      strokeWidth: strokeWidth ?? RefreshProgressIndicator.defaultStrokeWidth,
      triggerMode: triggerMode ?? RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}
