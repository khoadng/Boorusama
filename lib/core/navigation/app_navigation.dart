// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/material.dart';

final class AppNavigation {
  AppNavigation()
    : navigatorKey = GlobalKey<NavigatorState>(),
      routeObserver = RouteObserver<ModalRoute<dynamic>>();

  final GlobalKey<NavigatorState> navigatorKey;
  final RouteObserver<ModalRoute<dynamic>> routeObserver;
}

final appNavigationProvider = Provider<AppNavigation>(
  (_) => AppNavigation(),
  name: 'appNavigationProvider',
);
