// Flutter imports:
import 'package:flutter/material.dart';

typedef HomePageControllerOpenHandler = void Function(bool open);

class HomePageController extends ValueNotifier<int> {
  HomePageController({
    required this.scaffoldKey,
  }) : super(0) {
    _isMenuOpen = scaffoldKey.currentState?.isDrawerOpen ?? false;
  }

  final GlobalKey<ScaffoldState> scaffoldKey;

  final List<HomePageControllerOpenHandler> handlers = [];

  var _isMenuOpen = false;

  void goToTab(int index) {
    value = index;
  }

  void addHandler(HomePageControllerOpenHandler handler) {
    handlers.add(handler);
  }

  void removeHandler(HomePageControllerOpenHandler handler) {
    handlers.remove(handler);
  }

  void toggleMenu() {
    if (_isMenuOpen) {
      closeMenu();
    } else {
      openMenu();
    }
  }

  void openMenu() {
    scaffoldKey.currentState?.openDrawer();
    _isMenuOpen = true;

    for (final handler in handlers) {
      handler(true);
    }
  }

  void closeMenu() {
    scaffoldKey.currentState?.closeDrawer();
    _isMenuOpen = false;

    for (final handler in handlers) {
      handler(false);
    }
  }
}

class InheritedHomePageController extends InheritedWidget {
  const InheritedHomePageController({
    required this.controller,
    required super.child,
    super.key,
  });

  final HomePageController controller;

  static HomePageController of(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedHomePageController>();

    return result!.controller;
  }

  static HomePageController? maybeOf(BuildContext context) {
    final result = context
        .dependOnInheritedWidgetOfExactType<InheritedHomePageController>();

    return result?.controller;
  }

  @override
  bool updateShouldNotify(InheritedHomePageController oldWidget) {
    return oldWidget.controller != controller;
  }
}
