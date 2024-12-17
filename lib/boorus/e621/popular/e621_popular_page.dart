// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/explores/explore.dart';
import '../../../core/posts/explores/widgets.dart';
import '../../../core/posts/listing/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/widgets/widgets.dart';
import '../posts/posts.dart';

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
                  color: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
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
