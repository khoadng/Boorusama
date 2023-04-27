// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart' hide LoadStatus;
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/datetime_selector.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/time_scale_toggle_switch.dart';
import 'package:boorusama/boorus/moebooru/application/popular/moebooru_popular_cubit.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';

class MoebooruPopularPage extends StatefulWidget {
  const MoebooruPopularPage({
    super.key,
  });

  @override
  State<MoebooruPopularPage> createState() => _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends State<MoebooruPopularPage>
    with MoebooruPopularPostCubitMixin {
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
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              child: BlocBuilder<MoebooruPopularPostCubit,
                  MoebooruPopularPostState>(
                builder: (context, state) {
                  return DateTimeSelector(
                    onDateChanged: changeDate,
                    date: state.extra.dateTime,
                    scale: _convertToTimeScale(state.extra.popularType),
                    backgroundColor: Colors.transparent,
                  );
                },
              ),
            ),
            TimeScaleToggleSwitch(
                onToggle: (category) =>
                    changePopularType(_convertToMoebooruPopularType(category))),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<MoebooruPopularPostCubit,
                  MoebooruPopularPostState>(
                builder: (context, state) {
                  return MoebooruInfinitePostList(
                    refreshing: state.refreshing,
                    loading: state.loading,
                    hasMore: state.hasMore,
                    error: state.error,
                    data: state.data,
                    scrollController: _scrollController,
                    onRefresh: () => refresh(),
                    sliverHeaderBuilder: (context) => [],
                    onLoadMore: fetch,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TimeScale _convertToTimeScale(MoebooruPopularType popularType) {
  switch (popularType) {
    case MoebooruPopularType.day:
    case MoebooruPopularType.recent:
      return TimeScale.day;
    case MoebooruPopularType.week:
      return TimeScale.week;
    case MoebooruPopularType.month:
      return TimeScale.month;
  }
}

MoebooruPopularType _convertToMoebooruPopularType(TimeScale timeScale) {
  switch (timeScale) {
    case TimeScale.day:
      return MoebooruPopularType.day;
    case TimeScale.week:
      return MoebooruPopularType.week;
    case TimeScale.month:
      return MoebooruPopularType.month;
  }
}
