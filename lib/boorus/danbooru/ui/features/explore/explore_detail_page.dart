// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_curated_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_most_viewed_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/post/post_popular_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'datetime_selector.dart';
import 'explore_post_grid.dart';

class ExploreDetail extends StatefulWidget {
  const ExploreDetail({
    Key? key,
    required this.title,
    required this.builder,
  }) : super(key: key);

  final Widget title;
  final Widget Function(
    BuildContext context,
    RefreshController refreshController,
    AutoScrollController scrollController,
  ) builder;

  @override
  State<ExploreDetail> createState() => _ExploreDetailState();
}

class _ExploreDetailState extends State<ExploreDetail> {
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
      body: BlocConsumer<ExploreDetailBloc, ExploreDetailState>(
        listener: (context, state) {
          _scrollController.jumpTo(0);
          _refreshController.requestRefresh();
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: widget.builder(
                  context,
                  _refreshController,
                  _scrollController,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExploreDetailPage extends StatelessWidget {
  const ExploreDetailPage({
    Key? key,
    required this.title,
    required this.category,
  }) : super(key: key);

  final Widget title;
  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreDetailBloc, ExploreDetailState>(
      builder: (context, state) {
        return ExploreDetail(
          title: title,
          builder: (context, refreshController, scrollController) {
            if (category == ExploreCategory.popular) {
              return BlocProvider(
                create: (context) => PostPopularBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostPopularRefreshed(
                      date: state.date,
                      scale: state.scale,
                    ),
                  ),
                child: BlocBuilder<PostPopularBloc, PostPopularState>(
                  builder: (context, ppstate) => ExplorePostGrid(
                    header: DateAndTimeScaleHeader(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      onTimeScaleChanged: (scale) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailTimeScaleChanged(scale)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
                    controller: refreshController,
                    date: state.date,
                    scale: state.scale,
                    status: ppstate.status,
                    posts: ppstate.posts,
                    onLoadMore: (date, scale) => context
                        .read<PostPopularBloc>()
                        .add(PostPopularFetched(date: date, scale: scale)),
                    onRefresh: (date, scale) => context
                        .read<PostPopularBloc>()
                        .add(PostPopularRefreshed(date: date, scale: scale)),
                  ),
                ),
              );
            } else if (category == ExploreCategory.curated) {
              return BlocProvider(
                create: (context) => PostCuratedBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostCuratedRefreshed(
                      date: state.date,
                      scale: state.scale,
                    ),
                  ),
                child: BlocBuilder<PostCuratedBloc, PostCuratedState>(
                  builder: (context, ppstate) => ExplorePostGrid(
                    header: DateAndTimeScaleHeader(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      onTimeScaleChanged: (scale) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailTimeScaleChanged(scale)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
                    controller: refreshController,
                    date: state.date,
                    scale: state.scale,
                    status: ppstate.status,
                    posts: ppstate.posts,
                    onLoadMore: (date, scale) => context
                        .read<PostCuratedBloc>()
                        .add(PostCuratedFetched(date: date, scale: scale)),
                    onRefresh: (date, scale) => context
                        .read<PostCuratedBloc>()
                        .add(PostCuratedRefreshed(date: date, scale: scale)),
                  ),
                ),
              );
            } else {
              return BlocProvider(
                create: (context) => PostMostViewedBloc(
                  postRepository: context.read<IPostRepository>(),
                  blacklistedTagsRepository:
                      context.read<BlacklistedTagsRepository>(),
                )..add(
                    PostMostViewedRefreshed(
                      date: state.date,
                    ),
                  ),
                child: BlocBuilder<PostMostViewedBloc, PostMostViewedState>(
                  builder: (context, ppstate) => ExplorePostGrid(
                    header: DateTimeSelector(
                      onDateChanged: (date) => context
                          .read<ExploreDetailBloc>()
                          .add(ExploreDetailDateChanged(date)),
                      date: state.date,
                      scale: state.scale,
                    ),
                    hasMore: ppstate.hasMore,
                    scrollController: scrollController,
                    controller: refreshController,
                    date: state.date,
                    scale: state.scale,
                    status: ppstate.status,
                    posts: ppstate.posts,
                    onLoadMore: (date, scale) => context
                        .read<PostMostViewedBloc>()
                        .add(PostMostViewedFetched(date: date)),
                    onRefresh: (date, scale) => context
                        .read<PostMostViewedBloc>()
                        .add(PostMostViewedRefreshed(date: date)),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class DateAndTimeScaleHeader extends StatelessWidget {
  const DateAndTimeScaleHeader({
    Key? key,
    required this.onDateChanged,
    required this.onTimeScaleChanged,
    required this.date,
    required this.scale,
  }) : super(key: key);

  final void Function(DateTime date) onDateChanged;
  final void Function(TimeScale scale) onTimeScaleChanged;
  final DateTime date;
  final TimeScale scale;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DateTimeSelector(
          onDateChanged: onDateChanged,
          date: date,
          scale: scale,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TimeScaleSelectButton(
              scale: scale,
              onTimeScaleChanged: onTimeScaleChanged,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

class _TimeScaleSelectButton extends StatelessWidget {
  const _TimeScaleSelectButton({
    Key? key,
    required this.scale,
    required this.onTimeScaleChanged,
  }) : super(key: key);

  final TimeScale scale;
  final void Function(TimeScale scale) onTimeScaleChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 4,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<TimeScale>(
            alignment: AlignmentDirectional.center,
            isDense: true,
            value: scale,
            focusColor: Colors.transparent,
            icon: const Padding(
              padding: EdgeInsets.only(left: 5, top: 2),
              child: Icon(Icons.arrow_drop_down),
            ),
            onChanged: (newValue) {
              if (newValue != null) onTimeScaleChanged(newValue);
            },
            items: TimeScale.values.map<DropdownMenuItem<TimeScale>>((value) {
              return DropdownMenuItem<TimeScale>(
                value: value,
                child: Text(
                  _timeScaleToString(value).tr().toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.headline6!.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

String _timeScaleToString(TimeScale scale) {
  switch (scale) {
    case TimeScale.month:
      return 'dateRange.month';
    case TimeScale.week:
      return 'dateRange.week';
    default:
      return 'dateRange.day';
  }
}
