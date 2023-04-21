// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_improved_scrolling/flutter_improved_scrolling.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/ui/multi_select_controller.dart';
import 'package:boorusama/core/ui/multi_select_widget.dart';

class InfinitePostList<T> extends StatefulWidget {
  const InfinitePostList({
    super.key,
    required this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.hasMore,
    required this.itemBuilder,
    this.footerBuilder,
    this.headerBuilder,
    required this.items,
    required this.bodyBuilder,
    required this.loading,
    this.multiSelectController,
  });

  final VoidCallback onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;

  final bool hasMore;
  final bool loading;

  final List<T> items;
  final IndexedWidgetBuilder itemBuilder;
  final FooterBuilder<T>? footerBuilder;
  final HeaderBuilder<T>? headerBuilder;
  final Widget Function(BuildContext context, IndexedWidgetBuilder itemBuilder)
      bodyBuilder;

  final MultiSelectController<T>? multiSelectController;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  State<InfinitePostList<T>> createState() => _InfinitePostListState();
}

class _InfinitePostListState<T> extends State<InfinitePostList<T>>
    with TickerProviderStateMixin {
  late final AutoScrollController _autoScrollController;
  late final MultiSelectController<T> _multiSelectController;
  late AnimationController _animationController;

  final ValueNotifier<bool> _isOnTop = ValueNotifier(false);
  var multiSelect = false;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
    _multiSelectController =
        widget.multiSelectController ?? MultiSelectController<T>();

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

    if (widget.multiSelectController == null) {
      _multiSelectController.dispose();
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
    if (_isBottom && widget.hasMore) widget.onLoadMore.call();
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
    return WillPopScope(
        onWillPop: _onWillPop,
        child: MultiSelectWidget<T>(
          footerBuilder: widget.footerBuilder,
          multiSelectController: _multiSelectController,
          onMultiSelectChanged: (p0) => setState(() {
            multiSelect = p0;
          }),
          headerBuilder: (context, selected, clearSelected) =>
              widget.headerBuilder != null
                  ? widget.headerBuilder!(context, selected, clearSelected)
                  : AppBar(
                      leading: IconButton(
                        onPressed: () =>
                            _multiSelectController.disableMultiSelect(),
                        icon: const Icon(Icons.close),
                      ),
                      actions: [
                        IconButton(
                          onPressed: clearSelected,
                          icon: const Icon(Icons.clear_all),
                        ),
                      ],
                      title: selected.isEmpty
                          ? const Text('Select items')
                          : Text('${selected.length} Items selected'),
                    ),
          items: widget.items,
          itemBuilder: widget.itemBuilder,
          scrollableWidgetBuilder: (context, items, itemBuilder) {
            return Scaffold(
              floatingActionButton: FadeTransition(
                opacity: _animationController,
                child: ScaleTransition(
                  scale: _animationController,
                  child: widget.extendBody
                      ? Padding(
                          padding: EdgeInsets.only(
                            bottom: widget.extendBodyHeight ??
                                kBottomNavigationBarHeight,
                          ),
                          child: FloatingActionButton(
                            heroTag: null,
                            child: const FaIcon(FontAwesomeIcons.angleUp),
                            onPressed: () => _autoScrollController.jumpTo(0),
                          ),
                        )
                      : FloatingActionButton(
                          heroTag: null,
                          child: const FaIcon(FontAwesomeIcons.angleUp),
                          onPressed: () => _autoScrollController.jumpTo(0),
                        ),
                ),
              ),
              body: RefreshIndicator(
                notificationPredicate:
                    widget.onRefresh != null ? (_) => true : (_) => false,
                onRefresh: () async {
                  widget.onRefresh?.call();
                  _multiSelectController.clearSelected();
                  await Future.delayed(
                    const Duration(seconds: 1),
                  );
                },
                child: ImprovedScrolling(
                  scrollController: _autoScrollController,
                  enableKeyboardScrolling: true,
                  enableMMBScrolling: true,
                  child: CustomScrollView(
                    controller: _autoScrollController,
                    slivers: [
                      if (!multiSelect && widget.sliverHeaderBuilder != null)
                        ...widget.sliverHeaderBuilder!(context),
                      widget.bodyBuilder(context, itemBuilder),
                      if (widget.loading)
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
                ),
              ),
            );
          },
        ));
  }

  Future<bool> _onWillPop() async {
    if (multiSelect) {
      _multiSelectController.disableMultiSelect();

      return false;
    } else {
      return true;
    }
  }
}
