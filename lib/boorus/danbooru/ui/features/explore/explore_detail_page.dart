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
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
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

PostFetcher _categoryToFetcher(
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
) {
  if (category == ExploreCategory.curated) {
    return CuratedPostFetcher(date: date, scale: scale);
  } else if (category == ExploreCategory.popular) {
    return PopularPostFetcher(date: date, scale: scale);
  } else if (category == ExploreCategory.hot) {
    return const HotPostFetcher();
  } else {
    return MostViewedPostFetcher(date: date);
  }
}

Widget _categoryToListHeader(
  BuildContext context,
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
) {
  if (category == ExploreCategory.curated ||
      category == ExploreCategory.popular) {
    return DateAndTimeScaleHeader(
      onDateChanged: (date) =>
          context.read<ExploreDetailBloc>().add(ExploreDetailDateChanged(date)),
      onTimeScaleChanged: (scale) => context
          .read<ExploreDetailBloc>()
          .add(ExploreDetailTimeScaleChanged(scale)),
      date: date,
      scale: scale,
    );
  } else if (category == ExploreCategory.hot) {
    return const SizedBox.shrink();
  } else {
    return DateTimeSelector(
      onDateChanged: (date) =>
          context.read<ExploreDetailBloc>().add(ExploreDetailDateChanged(date)),
      date: date,
      scale: scale,
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
            return BlocProvider(
              create: (context) => PostBloc(
                postRepository: context.read<IPostRepository>(),
                blacklistedTagsRepository:
                    context.read<BlacklistedTagsRepository>(),
                favoritePostRepository: context.read<IFavoritePostRepository>(),
                accountRepository: context.read<IAccountRepository>(),
              )..add(
                  PostRefreshed(
                      fetcher: _categoryToFetcher(
                          category, state.date, state.scale)),
                ),
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, ppstate) => ExplorePostGrid(
                  header: _categoryToListHeader(
                    context,
                    category,
                    state.date,
                    state.scale,
                  ),
                  hasMore: ppstate.hasMore,
                  scrollController: scrollController,
                  controller: refreshController,
                  date: state.date,
                  scale: state.scale,
                  status: ppstate.status,
                  posts: ppstate.posts,
                  onLoadMore: (date, scale) => context.read<PostBloc>().add(
                      PostFetched(
                          tags: '',
                          fetcher: _categoryToFetcher(category, date, scale))),
                  onRefresh: (date, scale) => context.read<PostBloc>().add(
                      PostRefreshed(
                          fetcher: _categoryToFetcher(category, date, scale))),
                ),
              ),
            );
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
