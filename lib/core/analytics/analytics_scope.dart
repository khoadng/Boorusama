// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/current.dart';
import 'analytics_providers.dart';
import 'analytics_view_info.dart';

class AnalyticsScope extends ConsumerStatefulWidget {
  const AnalyticsScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AnalyticsScope> createState() => _AnalyticsScopeState();
}

class _AnalyticsScopeState extends ConsumerState<AnalyticsScope>
    with WidgetsBindingObserver {
  double? _lastAspectRatio;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateViewInfo();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _updateViewInfo();
  }

  void _updateViewInfo() {
    final aspectRatio = View.of(context).physicalSize.aspectRatio;

    if (_lastAspectRatio == aspectRatio) return;

    ref.read(analyticsProvider).whenData(
          (a) => a.updateViewInfo(
            AnalyticsViewInfo(aspectRatio: aspectRatio),
          ),
        );

    _lastAspectRatio = aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      currentBooruConfigProvider,
      (p, c) {
        if (p != c) {
          ref.watch(analyticsProvider).whenData((a) {
            if (a.enabled) {
              a.changeCurrentAnalyticConfig(c);
            }
          });
        }
      },
    );

    return widget.child;
  }
}
