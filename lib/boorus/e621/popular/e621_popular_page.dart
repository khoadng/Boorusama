// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/datetimes/datetime_selector.dart';
import 'package:boorusama/core/datetimes/time_scale_toggle_switch.dart';
import 'package:boorusama/core/datetimes/types.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/core/posts/listing.dart';
import 'package:boorusama/core/theme.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/functional.dart';

class E621PopularPage extends ConsumerStatefulWidget {
  const E621PopularPage({
    super.key,
  });

  @override
  ConsumerState<E621PopularPage> createState() => _E621PopularPageState();
}

class _E621PopularPageState extends ConsumerState<E621PopularPage> {
  final selectedDateNotifier = ValueNotifier(DateTime.now());
  final selectedTimescale = ValueNotifier(TimeScale.day);

  E621PopularRepository get repo =>
      ref.read(e621PopularPostRepoProvider(ref.readConfigAuth));

  DateTime get selectedDate => selectedDateNotifier.value;
  TimeScale get scale => selectedTimescale.value;

  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: Scaffold(
        body: SafeArea(
          child: PostScope(
            fetcher: (page) => page > 1
                ? TaskEither.of(<E621Post>[].toResult())
                : repo.getPopularPosts(selectedDate, scale),
            builder: (context, controller) => Column(
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
                  child: PostGrid(
                    controller: controller,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
