import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class KurumiScrollToTop extends StatefulWidget {
  const KurumiScrollToTop({
    required this.child,
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;
  final Widget child;

  @override
  State<KurumiScrollToTop> createState() => _KurumiScrollToTopState();
}

class _KurumiScrollToTopState extends State<KurumiScrollToTop>
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

class KurumiScrollToBottom extends StatefulWidget {
  const KurumiScrollToBottom({
    required this.child,
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;
  final Widget child;

  @override
  State<KurumiScrollToBottom> createState() => _KurumiScrollToBottomState();
}

class _KurumiScrollToBottomState extends State<KurumiScrollToBottom>
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

extension KurumiScrollControllerPositionX on ScrollController {
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
