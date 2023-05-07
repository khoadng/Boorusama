import 'package:flutter/material.dart';

class HideOnScroll extends StatefulWidget {
  const HideOnScroll({super.key, this.scrollNotification, required this.child});

  final ScrollNotification? scrollNotification;
  final Widget child;
  @override
  State<HideOnScroll> createState() => _HideOnScrollState();
}

class _HideOnScrollState extends State<HideOnScroll>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      reverseDuration: kThemeAnimationDuration,
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      reverseDuration: kThemeAnimationDuration,
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(HideOnScroll oldWidget) {
    super.didUpdateWidget(oldWidget);

    final notification = widget.scrollNotification;
    if (notification != null && notification is ScrollUpdateNotification) {
      if (notification.metrics.pixels > notification.metrics.minScrollExtent) {
        if (notification.scrollDelta! > 0 &&
            _fadeController.status != AnimationStatus.dismissed) {
          _fadeController.reverse();
          _scaleController.reverse();
        } else if (notification.scrollDelta! < 0 &&
            _fadeController.status != AnimationStatus.completed) {
          _fadeController.forward();
          _scaleController.forward();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeController,
      child: ScaleTransition(
        scale: _scaleController,
        child: widget.child,
      ),
    );
  }
}
