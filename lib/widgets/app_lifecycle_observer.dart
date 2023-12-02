// Flutter imports:
import 'package:flutter/material.dart';

class AppLifecycleObserver extends StatefulWidget {
  const AppLifecycleObserver({
    super.key,
    required this.child,
    this.onStateChange,
    this.onInactive,
    this.onResume,
    this.onHide,
    // this.onShow,
    this.onPause,
    // this.onRestart,
    // this.onExitRequested,
    this.onDetach,
  });

  final ValueChanged<AppLifecycleState>? onStateChange;
  final VoidCallback? onInactive;
  final VoidCallback? onResume;
  final VoidCallback? onHide;
  // final VoidCallback? onShow;
  final VoidCallback? onPause;
  // final VoidCallback? onRestart;
  // final AppExitRequestCallback? onExitRequested;
  final VoidCallback? onDetach;

  final Widget child;

  @override
  State<AppLifecycleObserver> createState() => _AppLifecycleObserverState();
}

class _AppLifecycleObserverState extends State<AppLifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onStateChange?.call(state);

    switch (state) {
      case AppLifecycleState.inactive:
        widget.onInactive?.call();
        break;
      case AppLifecycleState.resumed:
        widget.onResume?.call();
        break;
      case AppLifecycleState.paused:
        widget.onPause?.call();
        break;
      case AppLifecycleState.detached:
        widget.onDetach?.call();
        break;
      case AppLifecycleState.hidden:
        widget.onHide?.call();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
