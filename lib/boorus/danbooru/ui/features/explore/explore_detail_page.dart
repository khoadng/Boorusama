// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'datetime_selector.dart';
import 'explore_post_grid.dart';
import 'time_scale_toggle_switch.dart';

class _ExploreDetail extends StatefulWidget {
  const _ExploreDetail({
    required this.title,
    required this.builder,
  });

  final Widget title;
  final Widget Function(
    BuildContext context,
    RefreshController refreshController,
    AutoScrollController scrollController,
  ) builder;

  @override
  State<_ExploreDetail> createState() => _ExploreDetailState();
}

class _ExploreDetailState extends State<_ExploreDetail> {
  final RefreshController _refreshController = RefreshController();
  final AutoScrollController _scrollController = AutoScrollController();

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
      ),
      body: BlocListener<ExploreDetailBloc, ExploreDetailState>(
        listener: (context, state) {
          _scrollController.jumpTo(0);
          _refreshController.requestRefresh();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: widget.builder(
            context,
            _refreshController,
            _scrollController,
          ),
        ),
      ),
    );
  }
}

PostFetcher _categoryToFetcher(
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
  BuildContext context,
) {
  if (category == ExploreCategory.curated) {
    return CuratedPostFetcher(
      date: date,
      scale: scale,
      exploreRepository: context.read<ExploreRepository>(),
    );
  } else if (category == ExploreCategory.popular) {
    return PopularPostFetcher(
      date: date,
      scale: scale,
      exploreRepository: context.read<ExploreRepository>(),
    );
  } else if (category == ExploreCategory.hot) {
    return HotPostFetcher(
      exploreRepository: context.read<ExploreRepository>(),
    );
  } else {
    return MostViewedPostFetcher(
      date: date,
      exploreRepository: context.read<ExploreRepository>(),
    );
  }
}

List<Widget> _categoryToListHeader(
  BuildContext context,
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
) {
  switch (category) {
    case ExploreCategory.popular:
    case ExploreCategory.curated:
      return [
        TimeScaleToggleSwitch(
          onToggle: (scale) => {
            context
                .read<ExploreDetailBloc>()
                .add(ExploreDetailTimeScaleChanged(scale)),
          },
        ),
        const SizedBox(height: 20),
      ];
    case ExploreCategory.mostViewed:
    case ExploreCategory.hot:
      return [];
  }
}

class ExploreDetailPage extends StatelessWidget {
  const ExploreDetailPage({
    super.key,
    required this.title,
    required this.category,
  });

  final Widget title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ExploreDetailBloc>().state;

    return _ExploreDetail(
      title: title,
      builder: (context, refreshController, scrollController) {
        return BlocProvider(
          create: (context) => PostBloc.of(context)
            ..add(
              PostRefreshed(
                fetcher: _categoryToFetcher(
                  category,
                  state.date,
                  state.scale,
                  context,
                ),
              ),
            ),
          child: _ExplorePostGrid(
            category: category,
            scrollController: scrollController,
            refreshController: refreshController,
            date: state.date,
            scale: state.scale,
          ),
        );
      },
    );
  }
}

class _ExplorePostGrid extends StatelessWidget {
  const _ExplorePostGrid({
    required this.category,
    required this.scrollController,
    required this.refreshController,
    required this.date,
    required this.scale,
  });

  final ExploreCategory category;
  final TimeScale scale;
  final DateTime date;
  final AutoScrollController scrollController;
  final RefreshController refreshController;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostBloc>().state;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ExplorePostGrid(
              headers: _categoryToListHeader(
                context,
                category,
                date,
                scale,
              ),
              hasMore: state.hasMore,
              isLoading: state.loading,
              scrollController: scrollController,
              controller: refreshController,
              date: date,
              scale: scale,
              status: state.status,
              posts: state.posts,
              onLoadMore: (date, scale) => context
                  .read<PostBloc>()
                  .add(PostFetched(
                    tags: '',
                    fetcher: _categoryToFetcher(category, date, scale, context),
                  )),
              onRefresh: (date, scale) => context.read<PostBloc>().add(
                    PostRefreshed(
                      fetcher: _categoryToFetcher(
                        category,
                        date,
                        scale,
                        context,
                      ),
                    ),
                  ),
            ),
          ),
          if (category != ExploreCategory.hot)
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) => context
                    .read<ExploreDetailBloc>()
                    .add(ExploreDetailDateChanged(date)),
                date: date,
                scale: scale,
                backgroundColor: Colors.transparent,
              ),
            ),
        ],
      ),
    );
  }
}
