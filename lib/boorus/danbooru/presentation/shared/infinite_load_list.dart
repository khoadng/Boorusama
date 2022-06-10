// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/core/presentation/hooks/hooks.dart';
import 'sliver_post_grid.dart';

typedef RefreshCallback<T> = void Function(List<T> data);
typedef LoadMoreCallback<T> = void Function(List<T> data, int page);
typedef ErrorCallback<T> = void Function(String message);
typedef RefreshBuilder<T> = Future<List<T>> Function(int page);
typedef LoadMoreBuilder<T> = Future<List<T>> Function(int page);

class InfiniteLoadListController<T> extends ChangeNotifier {
  InfiniteLoadListController({
    required this.onData,
    required this.onMoreData,
    required this.onError,
    required this.refreshBuilder,
    required this.loadMoreBuilder,
  });

  final LoadMoreBuilder<T> loadMoreBuilder;
  final RefreshCallback<T> onData;
  final LoadMoreCallback<T> onMoreData;
  final ErrorCallback<T> onError;
  final RefreshBuilder<T> refreshBuilder;

  bool _isLoading = false;
  bool _isRefreshing = false;
  int _page = 1;
  final RefreshController _refreshController = RefreshController();

  get page => _page;

  get isRefreshing => _isRefreshing;

  get isLoading => _isLoading;

  get refreshController => _refreshController;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void refresh() async {
    _isRefreshing = true;
    _page = 1;
    notifyListeners();

    try {
      final data = await refreshBuilder(_page);
      onData(data);
      _refreshController.refreshCompleted();
    } on BooruException catch (e) {
      onError(e.message);
      _refreshController.refreshFailed();
    }

    _isRefreshing = false;
    notifyListeners();
  }

  void loadMore() async {
    _isLoading = true;
    _page = _page + 1;
    notifyListeners();

    try {
      final data = await loadMoreBuilder(_page);
      onMoreData(data, _page);
      if (data.isNotEmpty) {
        _refreshController.loadComplete();
      } else {
        _refreshController.loadNoData();
      }
    } on BooruException catch (e) {
      onError(e.message);
      _refreshController.loadFailed();
    }
    _isLoading = false;
    notifyListeners();
  }
}

class InfiniteLoadList extends HookWidget {
  const InfiniteLoadList({
    Key? key,
    required this.controller,
    required this.posts,
    this.onItemChanged,
    this.headers,
    this.child,
    this.enableRefresh = true,
    this.extendBody = false,

    /// Use this will disable scroll to index feature
    this.scrollController,
  }) : super(key: key);

  final Widget? child;
  final InfiniteLoadListController controller;
  final bool extendBody;
  final List<Widget>? headers;
  final ValueChanged<int>? onItemChanged;
  final bool enableRefresh;
  final ScrollController? scrollController;

  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    final autoScrollController = useState(AutoScrollController());

    useEffect(() {
      return () => autoScrollController.value.dispose;
    }, []);
    final hideFabAnimController = useAnimationController(
        duration: kThemeAnimationDuration, initialValue: 1);
    final scrollControllerWithAnim = useScrollControllerForAnimation(
        hideFabAnimController, scrollController ?? autoScrollController.value);

    void loadMoreIfNeeded(int index) {
      if (index > posts.length * 0.8) {
        controller.loadMore();
      }
    }

    return Scaffold(
      floatingActionButton: FadeTransition(
        opacity: hideFabAnimController,
        child: ScaleTransition(
          scale: hideFabAnimController,
          child: extendBody
              ? Padding(
                  padding:
                      const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
                  child: FloatingActionButton(
                    heroTag: null,
                    child: const FaIcon(FontAwesomeIcons.angleUp),
                    onPressed: () => scrollControllerWithAnim.jumpTo(0.0),
                  ),
                )
              : FloatingActionButton(
                  heroTag: null,
                  child: const FaIcon(FontAwesomeIcons.angleUp),
                  onPressed: () => scrollControllerWithAnim.jumpTo(0.0),
                ),
        ),
      ),
      body: SmartRefresher(
        controller: controller.refreshController,
        enablePullUp: true,
        enablePullDown: enableRefresh,
        header: const MaterialClassicHeader(),
        footer: const ClassicFooter(),
        onRefresh: () => controller.refresh(),
        onLoading: () => controller.loadMore(),
        child: CustomScrollView(
          controller: scrollControllerWithAnim,
          slivers: <Widget>[
            if (headers != null) ...headers!,
            child ??
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  sliver: SliverPostGrid(
                    onItemChanged: (index) {
                      loadMoreIfNeeded(index);
                      onItemChanged?.call(index);
                    },
                    posts: posts,
                    scrollController: autoScrollController.value,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class InfiniteLoadList2 extends StatefulWidget {
  const InfiniteLoadList2({
    Key? key,
    this.limit = 0.85,
    this.scrollController,
    this.refreshController,
    this.enableRefresh = true,
    this.onLoadMore,
    this.onRefresh,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.builder,
  }) : super(key: key);

  final bool extendBody;
  final double? extendBodyHeight;
  final bool enableRefresh;
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
  State<InfiniteLoadList2> createState() => _InfiniteLoadList2State();
}

class _InfiniteLoadList2State extends State<InfiniteLoadList2>
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
    if (_isBottom) widget.onLoadMore?.call();
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
                      bottom: widget.extendBodyHeight ??
                          kBottomNavigationBarHeight),
                  child: FloatingActionButton(
                    heroTag: null,
                    child: const FaIcon(FontAwesomeIcons.angleUp),
                    onPressed: () => _scrollController.jumpTo(0.0),
                  ),
                )
              : FloatingActionButton(
                  heroTag: null,
                  child: const FaIcon(FontAwesomeIcons.angleUp),
                  onPressed: () => _scrollController.jumpTo(0.0),
                ),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullUp: false,
        enablePullDown: widget.enableRefresh,
        header: const MaterialClassicHeader(),
        onRefresh: () => widget.onRefresh?.call(_refreshController),
        child: widget.builder(
          context,
          _scrollController,
        ),
      ),
    );
  }
}
