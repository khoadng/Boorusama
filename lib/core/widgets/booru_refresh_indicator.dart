// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';

class BooruRefreshIndicator extends ConsumerWidget {
  const BooruRefreshIndicator({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

    return RefreshIndicator(
      onRefresh: () {
        if (hapticLevel.isFull) {
          unawaited(HapticFeedback.mediumImpact());
        }
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
