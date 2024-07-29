// Flutter imports:
import 'package:boorusama/foundation/keyboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

class HomePageSidebarKeyboardListener extends StatefulWidget {
  const HomePageSidebarKeyboardListener({
    super.key,
    required this.controller,
    required this.child,
  });

  final HomePageController controller;
  final Widget child;

  @override
  State<HomePageSidebarKeyboardListener> createState() =>
      _HomePageSidebarKeyboardListenerState();
}

class _HomePageSidebarKeyboardListenerState
    extends State<HomePageSidebarKeyboardListener> with KeyboardListenerMixin {
  @override
  void initState() {
    super.initState();
    registerListener(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (isKeyPressed(
      LogicalKeyboardKey.keyB,
      controlOrMeta: true,
      event: event,
    )) {
      widget.controller.toggleMenu();
    }

    return false;
  }

  @override
  void dispose() {
    super.dispose();
    removeListener(_handleKeyEvent);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
