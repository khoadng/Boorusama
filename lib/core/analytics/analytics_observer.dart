// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'analytics_providers.dart';

class AnalyticsObserver implements NavigatorObserver {
  AnalyticsObserver(this.ref);

  final Ref Function() ref;

  NavigatorObserver? _obs;

  NavigatorObserver get observer =>
      _obs ??= ref().read(analyticsProvider).getAnalyticsObserver();

  @override
  void didChangeTop(Route topRoute, Route? previousTopRoute) {
    observer.didChangeTop(topRoute, previousTopRoute);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    observer.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    observer.didPush(route, previousRoute);
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    observer.didRemove(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    observer.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    observer.didStartUserGesture(route, previousRoute);
  }

  @override
  void didStopUserGesture() {
    observer.didStopUserGesture();
  }

  @override
  NavigatorState? get navigator => observer.navigator;
}
