// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/datetime_selector.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/time_scale_toggle_switch.dart';
import 'package:boorusama/boorus/moebooru/domain/posts.dart';
import 'package:boorusama/boorus/moebooru/ui/popular/types.dart';
import 'package:boorusama/boorus/moebooru/ui/posts.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/ui/posts/post_scope.dart';

class MoebooruPopularPage extends StatefulWidget {
  const MoebooruPopularPage({
    super.key,
  });

  @override
  State<MoebooruPopularPage> createState() => _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends State<MoebooruPopularPage> {
  final selectedDate = ValueNotifier(DateTime.now());
  final selectedPopular = ValueNotifier(MoebooruPopularType.day);

  PostsOrError _typeToData(MoebooruPopularType type, int page) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PostScope(
          fetcher: (page) => _typeToData(selectedPopular.value, page),
          builder: (context, controller, errors) => Column(
            children: [
              Container(
                color:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDate,
                  builder: (context, d, __) =>
                      ValueListenableBuilder<MoebooruPopularType>(
                    valueListenable: selectedPopular,
                    builder: (_, type, __) => DateTimeSelector(
                      onDateChanged: (date) {
                        selectedDate.value = date;
                        controller.refresh();
                      },
                      date: d,
                      scale: _convertToTimeScale(type),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              TimeScaleToggleSwitch(
                onToggle: (category) {
                  selectedPopular.value =
                      _convertToMoebooruPopularType(category);
                  controller.refresh();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: MoebooruInfinitePostList(
                  errors: errors,
                  controller: controller,
                  sliverHeaderBuilder: (context) => [],
                ),
              ),
            ],
          ),
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
