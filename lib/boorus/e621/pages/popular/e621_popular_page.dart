// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/types.dart';
import 'package:boorusama/boorus/core/widgets/datetime_selector.dart';
import 'package:boorusama/boorus/core/widgets/posts/post_scope.dart';
import 'package:boorusama/boorus/core/widgets/time_scale_toggle_switch.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/widgets/e621_infinite_post_list.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/functional.dart';

class E621PopularPage extends ConsumerStatefulWidget {
  const E621PopularPage({
    super.key,
  });

  @override
  ConsumerState<E621PopularPage> createState() => _MoebooruPopularPageState();
}

class _MoebooruPopularPageState extends ConsumerState<E621PopularPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  final selectedTimescale = ValueNotifier(TimeScale.day);

  E621PopularRepository get repo => ref.read(e621PopularPostRepoProvider);

  DateTime get selectedDate => selectedDateNotifier.value;
  TimeScale get scale => selectedTimescale.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PostScope(
          fetcher: (page) => page > 1
              ? TaskEither.of(<E621Post>[])
              : repo.getPopularPosts(selectedDate, scale),
          builder: (context, controller, errors) => Column(
            children: [
              Container(
                color: context.theme.bottomNavigationBarTheme.backgroundColor,
                child: ValueListenableBuilder<DateTime>(
                  valueListenable: selectedDateNotifier,
                  builder: (context, d, __) => ValueListenableBuilder(
                    valueListenable: selectedTimescale,
                    builder: (_, scale, __) => DateTimeSelector(
                      onDateChanged: (date) {
                        selectedDateNotifier.value = date;
                        controller.refresh();
                      },
                      date: d,
                      scale: scale,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
              TimeScaleToggleSwitch(
                onToggle: (category) {
                  selectedTimescale.value = category;
                  controller.refresh();
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: E621InfinitePostList(
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
