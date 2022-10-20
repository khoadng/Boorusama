// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:toggle_switch/toggle_switch.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'datetime_selector.dart';
import 'explore_post_grid.dart';

class ExploreDetail extends StatefulWidget {
  const ExploreDetail({
    Key? key,
    required this.title,
    required this.builder,
    this.actions,
  }) : super(key: key);

  final Widget title;
  final List<Widget>? actions;
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
        actions: widget.actions,
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

List<Widget> _categoryToListHeader(
  BuildContext context,
  ExploreCategory category,
  DateTime date,
  TimeScale scale,
) {
  if (category == ExploreCategory.curated ||
      category == ExploreCategory.popular) {
    return [
      DateTimeSelector(
        onDateChanged: (date) => context
            .read<ExploreDetailBloc>()
            .add(ExploreDetailDateChanged(date)),
        date: date,
        scale: scale,
      ),
      TimeScaleToggleSwitch(
        onToggle: (scale) => {
          context
              .read<ExploreDetailBloc>()
              .add(ExploreDetailTimeScaleChanged(scale)),
        },
      ),
      const SizedBox(height: 20),
    ];
  } else if (category == ExploreCategory.hot) {
    return [];
  } else {
    return [
      DateTimeSelector(
        onDateChanged: (date) => context
            .read<ExploreDetailBloc>()
            .add(ExploreDetailDateChanged(date)),
        date: date,
        scale: scale,
      ),
    ];
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
              create: (context) => PostBloc.of(context)
                ..add(
                  PostRefreshed(
                    fetcher:
                        _categoryToFetcher(category, state.date, state.scale),
                  ),
                ),
              child: BlocBuilder<PostBloc, PostState>(
                builder: (context, ppstate) => ExplorePostGrid(
                  headers: _categoryToListHeader(
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
                  onLoadMore: (date, scale) =>
                      context.read<PostBloc>().add(PostFetched(
                            tags: '',
                            fetcher: _categoryToFetcher(category, date, scale),
                          )),
                  onRefresh: (date, scale) => context.read<PostBloc>().add(
                        PostRefreshed(
                          fetcher: _categoryToFetcher(category, date, scale),
                        ),
                      ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class TimeScaleToggleSwitch extends StatefulWidget {
  const TimeScaleToggleSwitch({
    Key? key,
    required this.onToggle,
  }) : super(key: key);

  final void Function(TimeScale category) onToggle;

  @override
  State<TimeScaleToggleSwitch> createState() => _TimeScaleToggleSwitchState();
}

class _TimeScaleToggleSwitchState extends State<TimeScaleToggleSwitch> {
  final ValueNotifier<int> selected = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ValueListenableBuilder<int>(
        valueListenable: selected,
        builder: (context, value, _) => ToggleSwitch(
          dividerColor: Colors.black,
          changeOnTap: false,
          initialLabelIndex: value,
          minWidth: 80,
          minHeight: 30,
          cornerRadius: 5,
          labels: [
            _timeScaleToString(TimeScale.day).tr(),
            _timeScaleToString(TimeScale.week).tr(),
            _timeScaleToString(TimeScale.month).tr(),
          ],
          activeBgColor: [Theme.of(context).colorScheme.primary],
          inactiveBgColor: Theme.of(context).colorScheme.background,
          borderWidth: 1,
          borderColor: [Theme.of(context).hintColor],
          onToggle: (index) {
            if (index == 0) {
              widget.onToggle(TimeScale.day);
            } else if (index == 1) {
              widget.onToggle(TimeScale.week);
            } else {
              widget.onToggle(TimeScale.month);
            }

            selected.value = index ?? 0;
          },
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
