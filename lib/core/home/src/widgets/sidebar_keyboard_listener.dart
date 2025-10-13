// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../foundation/keyboard.dart';
import '../controllers/home_page_controller.dart';

class HomePageSidebarKeyboardListener extends StatefulWidget {
  const HomePageSidebarKeyboardListener({
    required this.controller,
    required this.child,
    super.key,
  });

  final HomePageController controller;
  final Widget child;

  @override
  State<HomePageSidebarKeyboardListener> createState() =>
      _HomePageSidebarKeyboardListenerState();
}

class _HomePageSidebarKeyboardListenerState
    extends State<HomePageSidebarKeyboardListener>
    with KeyboardListenerMixin {
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
