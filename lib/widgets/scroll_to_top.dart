// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

class ScrollToTop extends StatefulWidget {
  const ScrollToTop({
    super.key,
    this.scrollController,
    this.onBottomReached,
    required this.child,
  });

  final AutoScrollController? scrollController;
  final VoidCallback? onBottomReached;
  final Widget child;

  @override
  State<ScrollToTop> createState() => _ScrollToTopState();
}

class _ScrollToTopState extends State<ScrollToTop>
    with TickerProviderStateMixin {
  late final AutoScrollController _autoScrollController;
  late AnimationController _animationController;

  final ValueNotifier<bool> _isOnTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();

    _animationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      reverseDuration: kThemeAnimationDuration,
    );

    _autoScrollController.addListener(_onScroll);
    _isOnTop.addListener(_onTopReached);
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }

    _autoScrollController.removeListener(_onScroll);
    _isOnTop.removeListener(_onTopReached);

    _animationController.dispose();
    super.dispose();
  }

  void _onTopReached() {
    if (_isOnTop.value) {
      _animationController.reverse();
    }
  }

  void _onScroll() {
    switch (_autoScrollController.position.userScrollDirection) {
      case ScrollDirection.forward:
        _animationController.forward();
        break;
      case ScrollDirection.reverse:
        _animationController.reverse();
        break;
      case ScrollDirection.idle:
        break;
    }
    _isOnTop.value = _isTop;
    if (_isBottom) {
      widget.onBottomReached?.call();
    }
  }

  bool get _isBottom {
    if (!_autoScrollController.hasClients) return false;
    final maxScroll = _autoScrollController.position.maxScrollExtent;
    final currentScroll = _autoScrollController.offset;

    return currentScroll >= (maxScroll * 0.95);
  }

  bool get _isTop {
    if (!_autoScrollController.hasClients) return false;
    final currentScroll = _autoScrollController.offset;

    return currentScroll == 0;
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animationController,
      child: ScaleTransition(
        scale: _animationController,
        child: widget.child,
      ),
    );
  }
}
