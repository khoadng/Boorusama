// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

class ScrollToTop extends StatefulWidget {
  const ScrollToTop({
    required this.child,
    super.key,
    this.scrollController,
    this.onBottomReached,
  });

  final ScrollController? scrollController;
  final VoidCallback? onBottomReached;
  final Widget child;

  @override
  State<ScrollToTop> createState() => _ScrollToTopState();
}

class _ScrollToTopState extends State<ScrollToTop>
    with TickerProviderStateMixin {
  late final _scrollController =
      widget.scrollController ?? AutoScrollController();
  late final _animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
    reverseDuration: kThemeAnimationDuration,
  );

  final ValueNotifier<bool> _isOnTop = ValueNotifier(false);
  ScrollDirection? _lastDirection;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _isOnTop.addListener(_onTopReached);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    _isOnTop
      ..removeListener(_onTopReached)
      ..dispose();
    _animationController.dispose();

    super.dispose();
  }

  void _onTopReached() {
    if (_isOnTop.value) {
      _animationController.reverse();
    }
  }

  void _onScroll() {
    final position = _scrollController.position;

    // Avoid redundant animation calls based on scroll direction
    final currentDirection = position.userScrollDirection;
    if (currentDirection != _lastDirection) {
      _lastDirection = currentDirection;

      switch (currentDirection) {
        case ScrollDirection.forward:
          _animationController.forward();
        case ScrollDirection.reverse:
          _animationController.reverse();
        case ScrollDirection.idle:
          break;
      }
      _isOnTop.value = _scrollController.isTop;
      if (_scrollController.isBottom) {
        widget.onBottomReached?.call();
      }
    }
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

// scroll to bottom
class ScrollToBottom extends StatefulWidget {
  const ScrollToBottom({
    required this.child,
    super.key,
    this.scrollController,
    this.onTopReached,
  });

  final ScrollController? scrollController;
  final VoidCallback? onTopReached;
  final Widget child;

  @override
  State<ScrollToBottom> createState() => _ScrollToBottomState();
}

class _ScrollToBottomState extends State<ScrollToBottom>
    with TickerProviderStateMixin {
  late final _scrollController =
      widget.scrollController ?? AutoScrollController();
  late final _animationController = AnimationController(
    vsync: this,
    duration: kThemeAnimationDuration,
    reverseDuration: kThemeAnimationDuration,
  );

  final ValueNotifier<bool> _isOnBottom = ValueNotifier(false);

  ScrollDirection? _lastDirection;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    _isOnBottom.addListener(_onBottomReached);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    _isOnBottom
      ..removeListener(_onBottomReached)
      ..dispose();

    _animationController.dispose();
    super.dispose();
  }

  void _onBottomReached() {
    if (_isOnBottom.value) {
      _animationController.reverse();
    }
  }

  void _onScroll() {
    final position = _scrollController.position;

    // Avoid redundant animation calls based on scroll direction
    final currentDirection = position.userScrollDirection;
    if (currentDirection != _lastDirection) {
      _lastDirection = currentDirection;

      switch (currentDirection) {
        case ScrollDirection.forward:
          _animationController.reverse();
        case ScrollDirection.reverse:
          _animationController.forward();
        case ScrollDirection.idle:
          break;
      }
      _isOnBottom.value = _scrollController.isBottom;
      if (_scrollController.isTop) {
        widget.onTopReached?.call();
      }
    }
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

extension PositionExtensions on ScrollController {
  bool get isTop {
    if (!hasClients) return false;

    return offset == 0;
  }

  bool get isBottom {
    if (!hasClients) return false;

    final maxScroll = position.maxScrollExtent;
    final currentScroll = offset;

    return currentScroll >= (maxScroll * 0.95);
  }
}
