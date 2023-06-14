// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/datetime_selector.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/time_scale_toggle_switch.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/pages/popular/types.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/flutter.dart';

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

  MoebooruPopularRepository get repo => ref.read(moebooruPopularRepoProvider);

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
    return Scaffold(
      body: SafeArea(
        child: PostScope(
          fetcher: (page) => _typeToData(selectedPopular.value, page),
          builder: (context, controller, errors) => Column(
            children: [
              Container(
                color: context.theme.bottomNavigationBarTheme.backgroundColor,
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
