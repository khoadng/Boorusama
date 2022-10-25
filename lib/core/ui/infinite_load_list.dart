// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class InfiniteLoadList extends StatefulWidget {
  const InfiniteLoadList({
    super.key,
    this.limit = 0.95,
    this.scrollController,
    this.refreshController,
    this.enableRefresh = true,
    this.enableLoadMore = true,
    this.onLoadMore,
    this.onRefresh,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.builder,
  });

  final bool extendBody;
  final double? extendBodyHeight;
  final bool enableRefresh;
  final bool enableLoadMore;
  final double limit;
  final AutoScrollController? scrollController;
  final RefreshController? refreshController;
  final void Function(RefreshController controller)? onRefresh;
  final VoidCallback? onLoadMore;
  final Widget Function(
    BuildContext context,
    AutoScrollController controller,
  ) builder;

  @override
  State<InfiniteLoadList> createState() => _InfiniteLoadListState();
}

class _InfiniteLoadListState extends State<InfiniteLoadList>
    with TickerProviderStateMixin {
  late AutoScrollController _scrollController;
  late RefreshController _refreshController;
  late AnimationController _animationController;

  final ValueNotifier<bool> _isOnTop = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? AutoScrollController();
    _refreshController = widget.refreshController ?? RefreshController();
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

    if (widget.refreshController == null) {
      _refreshController.dispose();
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
        child: SmartRefresher(
          controller: _refreshController,
          enablePullDown: widget.enableRefresh,
          header: const MaterialClassicHeader(),
          onRefresh: () => widget.onRefresh?.call(_refreshController),
          child: widget.builder(
            context,
            _scrollController,
          ),
        ),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class InfiniteLoadListScrollView extends StatelessWidget {
  const InfiniteLoadListScrollView({
    super.key,
    required this.enableLoadMore,
    this.onLoadMore,
    this.onRefresh,
    required this.sliverBuilder,
    this.loadingBuilder,
    this.isLoading = false,
    this.scrollController,
    this.refreshController,
  });

  final bool enableLoadMore;
  final VoidCallback? onLoadMore;
  final void Function(RefreshController controller)? onRefresh;
  final List<Widget> Function(AutoScrollController scrollController)
      sliverBuilder;
  final Widget Function(BuildContext context, Widget child)? loadingBuilder;
  final bool isLoading;
  final AutoScrollController? scrollController;
  final RefreshController? refreshController;

  @override
  Widget build(BuildContext context) {
    return InfiniteLoadList(
      scrollController: scrollController,
      refreshController: refreshController,
      enableLoadMore: enableLoadMore,
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      builder: (context, controller) => CustomScrollView(
        controller: controller,
        slivers: [
          ...sliverBuilder(controller),
          if (isLoading)
            const SliverPadding(
              padding: EdgeInsets.symmetric(vertical: 20),
              sliver: SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            const SliverToBoxAdapter(child: SizedBox.shrink()),
        ],
      ),
    );
  }
}
