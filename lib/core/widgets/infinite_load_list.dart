// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/widgets/widgets.dart';

class InfiniteLoadList extends StatefulWidget {
  const InfiniteLoadList({
    super.key,
    this.scrollController,
    this.enableLoadMore = true,
    this.onLoadMore,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.builder,
    this.backgroundColor,
  });

  final bool extendBody;
  final double? extendBodyHeight;
  final bool enableLoadMore;
  final AutoScrollController? scrollController;
  final VoidCallback? onLoadMore;
  final Widget Function(
    BuildContext context,
    AutoScrollController controller,
  ) builder;
  final Color? backgroundColor;

  @override
  State<InfiniteLoadList> createState() => _InfiniteLoadListState();
}

class _InfiniteLoadListState extends State<InfiniteLoadList>
    with TickerProviderStateMixin {
  late AutoScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? AutoScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  void _onScrollToTop() {
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      floatingActionButton: ScrollToTop(
        scrollController: _scrollController,
        onBottomReached: () => widget.onLoadMore?.call(),
        child: widget.extendBody
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: widget.extendBodyHeight ?? kBottomNavigationBarHeight,
                ),
                child: BooruScrollToTopButton(
                  onPressed: _onScrollToTop,
                ),
              )
            : BooruScrollToTopButton(
                onPressed: _onScrollToTop,
              ),
      ),
      body: ImprovedScrolling(
        scrollController: _scrollController,
        enableMMBScrolling: true,
        child: widget.builder(
          context,
          _scrollController,
        ),
      ),
    );
  }
}
