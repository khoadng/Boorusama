// Flutter imports:
import 'package:boorusama/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfiniteLoadList extends StatefulWidget {
  const InfiniteLoadList({
    super.key,
    this.limit = 0.95,
    this.scrollController,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.onLoadMore,
    this.onRefresh,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.builder,
    this.backgroundColor,
    this.multiSelect = false,
    this.bottomBuilder,
    this.topBuilder,
  });

  final bool extendBody;
  final double? extendBodyHeight;
  final bool enableRefresh;
  final bool enableLoadMore;
  final double limit;
  final AutoScrollController? scrollController;
  final Future<void> Function()? onRefresh;
  final VoidCallback? onLoadMore;
  final Widget Function(
    BuildContext context,
    AutoScrollController controller,
  ) builder;
  final Color? backgroundColor;
  final bool multiSelect;
  final Widget Function()? bottomBuilder;
  final PreferredSizeWidget Function()? topBuilder;

  @override
  State<InfiniteLoadList> createState() => _InfiniteLoadListState();
}

class _InfiniteLoadListState extends State<InfiniteLoadList>
    with TickerProviderStateMixin {
  late AutoScrollController _scrollController;
  late AnimationController _animationController;

  final ValueNotifier<bool> _isOnTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? AutoScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      reverseDuration: kThemeAnimationDuration,
    );

    _scrollController.addListener(_onScroll);
    _isOnTop.addListener(_onTopReached);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _isOnTop.removeListener(_onTopReached);

    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    _animationController.dispose();
    super.dispose();
  }

  void _onTopReached() {
    if (_isOnTop.value) {
      _animationController.reverse();
    }
  }

  void _onScroll() {
    switch (_scrollController.position.userScrollDirection) {
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
    if (_isBottom && widget.enableLoadMore) widget.onLoadMore?.call();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * widget.limit);
  }

  bool get _isTop {
    if (!_scrollController.hasClients) return false;
    final currentScroll = _scrollController.offset;

    return currentScroll == 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.multiSelect ? widget.topBuilder?.call() : null,
      backgroundColor: widget.backgroundColor,
      bottomSheet: widget.multiSelect ? widget.bottomBuilder?.call() : null,
      floatingActionButton: FadeTransition(
        opacity: _animationController,
        child: ScaleTransition(
          scale: _animationController,
          child: widget.extendBody
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom:
                        widget.extendBodyHeight ?? kBottomNavigationBarHeight,
                  ),
                  child: FloatingActionButton(
                    heroTag: null,
                    child: const FaIcon(FontAwesomeIcons.angleUp),
                    onPressed: () => _scrollController.jumpTo(0),
                  ),
                )
              : FloatingActionButton(
                  heroTag: null,
                  child: const FaIcon(FontAwesomeIcons.angleUp),
                  onPressed: () => _scrollController.jumpTo(0),
                ),
        ),
      ),
      body: ImprovedScrolling(
        scrollController: _scrollController,
        enableKeyboardScrolling: true,
        enableMMBScrolling: true,
        child: ConditionalParentWidget(
          condition: widget.onRefresh != null,
          conditionalBuilder: (child) => RefreshIndicator(
            onRefresh: widget.onRefresh!,
            child: child,
          ),
          child: widget.builder(
            context,
            _scrollController,
          ),
        ),
      ),
    );
  }
}
