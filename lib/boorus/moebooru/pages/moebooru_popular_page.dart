// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/providers.dart';
import 'package:boorusama/core/datetimes/datetimes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/scaffolds/infinite_post_list_scaffold.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/functional.dart';
import '../feats/posts/posts.dart';

enum MoebooruPopularType {
  recent,
  day,
  week,
  month,
}

class MoebooruPopularPage extends ConsumerStatefulWidget {
  const MoebooruPopularPage({
    super.key,
  });

  @override
  ConsumerState<MoebooruPopularPage> createState() =>
      _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends ConsumerState<MoebooruPopularPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  final selectedPopular = ValueNotifier(MoebooruPopularType.day);

  MoebooruPopularRepository get repo =>
      ref.read(moebooruPopularRepoProvider(ref.readConfig));

  DateTime get selectedDate => selectedDateNotifier.value;

  PostsOrError _typeToData(MoebooruPopularType type, int page) =>
      switch (type) {
        MoebooruPopularType.recent =>
          repo.getPopularPostsRecent(MoebooruTimePeriod.day),
        MoebooruPopularType.day => repo.getPopularPostsByDay(selectedDate),
        MoebooruPopularType.week => repo.getPopularPostsByWeek(selectedDate),
        MoebooruPopularType.month => repo.getPopularPostsByMonth(selectedDate)
      };

  @override
  Widget build(BuildContext context) {
    return PostScope(
      fetcher: (page) => page > 1
          ? TaskEither.of(<Post>[].toResult())
          : _typeToData(selectedPopular.value, page),
      builder: (context, controller, errors) => Column(
        children: [
          Expanded(
            child: InfinitePostListScaffold(
              errors: errors,
              controller: controller,
              sliverHeaderBuilder: (context) => [
                SliverToBoxAdapter(
                  child: TimeScaleToggleSwitch(
                    onToggle: (category) {
                      selectedPopular.value =
                          _convertToMoebooruPopularType(category);
                      controller.refresh();
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: context.theme.bottomNavigationBarTheme.backgroundColor,
            margin: EdgeInsets.only(
              bottom: MediaQuery.viewPaddingOf(context).bottom,
            ),
            child: ValueListenableBuilder<DateTime>(
              valueListenable: selectedDateNotifier,
              builder: (context, d, __) =>
                  ValueListenableBuilder<MoebooruPopularType>(
                valueListenable: selectedPopular,
                builder: (_, type, __) => DateTimeSelector(
                  onDateChanged: (date) {
                    selectedDateNotifier.value = date;
                    controller.refresh();
                  },
                  date: d,
                  scale: _convertToTimeScale(type),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TimeScale _convertToTimeScale(MoebooruPopularType popularType) =>
    switch (popularType) {
      MoebooruPopularType.day || MoebooruPopularType.recent => TimeScale.day,
      MoebooruPopularType.week => TimeScale.week,
      MoebooruPopularType.month => TimeScale.month,
    };

MoebooruPopularType _convertToMoebooruPopularType(TimeScale timeScale) =>
    switch (timeScale) {
      TimeScale.day => MoebooruPopularType.day,
      TimeScale.week => MoebooruPopularType.week,
      TimeScale.month => MoebooruPopularType.month
    };
