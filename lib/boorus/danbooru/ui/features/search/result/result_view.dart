// Flutter imports:
import 'package:boorusama/boorus/danbooru/ui/shared/default_post_context_menu.dart';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/search/search_bloc.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/infinite_post_list.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/post_grid.dart';
import 'package:boorusama/core/application/search/tag_search_item.dart';
import 'package:boorusama/core/ui/pagination.dart';
import 'related_tag_section.dart';
import 'result_header.dart';

class ResultView extends StatefulWidget {
  const ResultView({
    super.key,
    this.headerBuilder,
    this.scrollController,
    this.backgroundColor,
  });

  final List<Widget> Function()? headerBuilder;
  final AutoScrollController? scrollController;
  final Color? backgroundColor;

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  final refreshController = RefreshController();
  late final scrollController =
      widget.scrollController ?? AutoScrollController();

  @override
  void dispose() {
    refreshController.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pagination = context.select((PostBloc bloc) => bloc.state.pagination);

    return pagination
        ? _Pagination(
            backgroundColor: widget.backgroundColor,
            scrollController: scrollController,
            headerBuilder: widget.headerBuilder,
          )
        : _InfiniteScroll(
            backgroundColor: widget.backgroundColor,
            scrollController: scrollController,
            refreshController: refreshController,
            headerBuilder: widget.headerBuilder,
          );
  }
}

class _InfiniteScroll extends StatelessWidget {
  const _InfiniteScroll({
    required this.scrollController,
    required this.refreshController,
    this.headerBuilder,
    this.backgroundColor,
  });

  final AutoScrollController scrollController;
  final RefreshController refreshController;
  final List<Widget> Function()? headerBuilder;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);

    return InfinitePostList(
      onLoadMore: () => context.read<PostBloc>().add(PostFetched(
            tags: tags.map((e) => e.toString()).join(' '),
            fetcher: SearchedPostFetcher.fromTags(
              tags.map((e) => e.toString()).join(' '),
            ),
          )),
      onRefresh: (controller) {
        context.read<PostBloc>().add(PostRefreshed(
              tag: tags.map((e) => e.toString()).join(' '),
              fetcher: SearchedPostFetcher.fromTags(
                tags.map((e) => e.toString()).join(' '),
              ),
            ));
      },
      sliverHeaderBuilder: (context) => [
        ...headerBuilder?.call() ?? [],
        const SliverToBoxAdapter(child: RelatedTagSection()),
        const SliverToBoxAdapter(child: ResultHeader()),
      ],
    );
  }
}

class _Pagination extends StatefulWidget {
  const _Pagination({
    required this.scrollController,
    this.headerBuilder,
    this.backgroundColor,
  });

  final AutoScrollController scrollController;
  final List<Widget> Function()? headerBuilder;
  final Color? backgroundColor;

  @override
  State<_Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<_Pagination>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: kThemeAnimationDuration,
      reverseDuration: kThemeAnimationDuration,
    );

    widget.scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    widget.scrollController.removeListener(_onScroll);
  }

  void _onScroll() {
    switch (widget.scrollController.position.userScrollDirection) {
      case ScrollDirection.forward:
        _animationController.forward();
        break;
      case ScrollDirection.reverse:
        _animationController.reverse();
        break;
      case ScrollDirection.idle:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchBloc bloc) => bloc.state.selectedTags);
    final totalResults =
        context.select((SearchBloc bloc) => bloc.state.totalResults);
    final maxPage =
        totalResults != null ? (totalResults / PostBloc.postPerPage).ceil() : 1;
    final state = context.watch<PostBloc>().state;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      floatingActionButton: FadeTransition(
        opacity: _animationController,
        child: ScaleTransition(
          scale: _animationController,
          child: FloatingActionButton(
            heroTag: null,
            child: const FaIcon(FontAwesomeIcons.angleUp),
            onPressed: () => widget.scrollController.jumpTo(0),
          ),
        ),
      ),
      body: CustomScrollView(
        physics: const NoImplicitScrollPhysics(),
        controller: widget.scrollController,
        slivers: [
          ...widget.headerBuilder?.call() ?? [],
          const SliverToBoxAdapter(child: RelatedTagSection()),
          const SliverToBoxAdapter(child: ResultHeader()),
          PostGrid(
            controller: widget.scrollController,
            onTap: () => FocusScope.of(context).unfocus(),
            contextMenuBuilder: (post) => DefaultPostContextMenu(
              post: post,
              // ignore: no-empty-block
              onMultiSelect: () {},
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          if (totalResults != null && totalResults >= PostBloc.postPerPage)
            SliverToBoxAdapter(
              child: PageSelector(
                currentPage: state.page,
                totalResults: totalResults,
                itemPerPage: PostBloc.postPerPage,
                onPrevious:
                    state.page > 1 ? () => _fetch(state.page - 1, tags) : null,
                onNext: maxPage != state.page
                    ? () => _fetch(state.page + 1, tags)
                    : null,
                onPageSelect: (page) => _fetch(page, tags),
              ),
            ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  void _fetch(int page, List<TagSearchItem> tags) {
    context.read<PostBloc>().add(PostFetched(
          page: page,
          tags: tags.map((e) => e.toString()).join(' '),
          fetcher: SearchedPostFetcher.fromTags(
            tags.map((e) => e.toString()).join(' '),
          ),
        ));
    widget.scrollController.jumpTo(0);
  }
}

class NoImplicitScrollPhysics extends AlwaysScrollableScrollPhysics {
  const NoImplicitScrollPhysics({super.parent});

  @override
  bool get allowImplicitScrolling => false;

  @override
  NoImplicitScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoImplicitScrollPhysics(parent: buildParent(ancestor));
  }
}
