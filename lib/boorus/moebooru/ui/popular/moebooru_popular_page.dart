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
import 'package:boorusama/boorus/moebooru/domain/posts.dart';
import 'package:boorusama/boorus/moebooru/ui/popular/types.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';

class MoebooruPopularPage extends StatefulWidget {
  const MoebooruPopularPage({
    super.key,
  });

  @override
  State<MoebooruPopularPage> createState() => _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends State<MoebooruPopularPage> {
  final RefreshController _refreshController = RefreshController();
  final AutoScrollController _scrollController = AutoScrollController();
  late final controller = PostGridController<Post>(
    fetcher: (page) => _typeToData(selectedPopular.value, page),
    refresher: () => _typeToData(selectedPopular.value, 1),
  );

  final selectedDate = ValueNotifier(DateTime.now());
  final selectedPopular = ValueNotifier(MoebooruPopularType.day);

  Future<List<Post>> _typeToData(MoebooruPopularType type, int page) {
    final repo = context.read<MoebooruPopularRepository>();
    switch (type) {
      case MoebooruPopularType.recent:
        return repo.getPopularPostsRecent(MoebooruTimePeriod.day);
      case MoebooruPopularType.day:
        return repo.getPopularPostsByDay(selectedDate.value);
      case MoebooruPopularType.week:
        return repo.getPopularPostsByWeek(selectedDate.value);
      case MoebooruPopularType.month:
        return repo.getPopularPostsByMonth(selectedDate.value);
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _scrollController.dispose();
    controller.dispose();
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
              child: DateTimeSelector(
                onDateChanged: (date) {
                  selectedDate.value = date;
                  setState(() {}); // FIXME: fix this
                  controller.refresh();
                },
                date: selectedDate.value,
                scale: _convertToTimeScale(selectedPopular.value),
                backgroundColor: Colors.transparent,
              ),
            ),
            TimeScaleToggleSwitch(
              onToggle: (category) {
                selectedPopular.value = _convertToMoebooruPopularType(category);
                setState(() {}); //FIXME: fix this
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: MoebooruInfinitePostList(
                controller: controller,
                scrollController: _scrollController,
                sliverHeaderBuilder: (context) => [],
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
