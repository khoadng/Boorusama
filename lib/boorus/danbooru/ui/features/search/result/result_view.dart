// Dart imports:
import 'dart:math' as math;

// Flutter imports:
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
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
          SliverToBoxAdapter(
            child: ButtonBar(
              buttonPadding: const EdgeInsets.symmetric(horizontal: 2),
              alignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: state.page > 1
                      ? () => _fetch(state.page - 1, tags)
                      : null,
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 32,
                  ),
                ),
                ...generatePage(
                  current: state.page,
                  total: totalResults,
                  postPerPage: PostBloc.postPerPage,
                ).map((page) => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        shadowColor: Colors.transparent,
                        backgroundColor: page == state.page
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                      ),
                      onPressed: () => _fetch(page, tags),
                      child: Text(
                        '$page',
                        style: page == state.page
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(color: Theme.of(context).hintColor),
                      ),
                    )),
                IconButton(
                  onPressed: maxPage != state.page
                      ? () => _fetch(state.page + 1, tags)
                      : null,
                  icon: const Icon(
                    Icons.chevron_right,
                    size: 32,
                  ),
                ),
              ],
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

List<int> generatePage({
  required int current,
  required int? total,
  required int postPerPage,
}) {
  if (total == null) return [1];

  final maxPage = (total / postPerPage).ceil();
  const maxSelectablePage = 4;
  if (current < maxSelectablePage) {
    return List.generate(
      maxSelectablePage,
      (index) => math.min(index + 1, maxPage),
    ).toSet().toList();
  }

  return List.generate(
    maxSelectablePage,
    (index) => math.min(current + index - 1, maxPage),
  ).toSet().toList();
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
