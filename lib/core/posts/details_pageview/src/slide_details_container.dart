// Flutter imports:
import 'package:flutter/material.dart';

enum SlideContainerDirection {
  up,
  down,
}

class SlideDetailsContainer extends StatefulWidget {
  const SlideDetailsContainer({
    required this.child,
    required this.shouldSlide,
    required this.direction,
    super.key,
  });

  final Widget child;
  final bool shouldSlide;
  final SlideContainerDirection direction;

  @override
  State<SlideDetailsContainer> createState() => _SlideDetailsContainerState();
}

class _SlideDetailsContainerState extends State<SlideDetailsContainer>
    with TickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      value: 0,
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SlideDetailsContainer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.shouldSlide != widget.shouldSlide) {
      _animController.animateTo(
        widget.shouldSlide ? 1 : 0,
        duration: widget.shouldSlide
            ? const Duration(milliseconds: 350)
            : const Duration(milliseconds: 150),
        curve: Curves.easeOutCirc,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: Offset.zero,
        end: switch (widget.direction) {
          SlideContainerDirection.up => const Offset(0, -1),
          SlideContainerDirection.down => const Offset(0, 1)
        },
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOut,
        ),
      ),
      child: widget.child,
    );
  }
}
