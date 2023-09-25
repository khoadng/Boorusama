// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';
import 'widgets/moebooru_infinite_post_list.dart';
import 'widgets/period_toggle_switch.dart';

class MoebooruPopularRecentPage extends ConsumerStatefulWidget {
  const MoebooruPopularRecentPage({
    super.key,
  });

  @override
  ConsumerState<MoebooruPopularRecentPage> createState() =>
      _MoebooruPopularPageState();
}

class _MoebooruPopularPageState
    extends ConsumerState<MoebooruPopularRecentPage> {
  final selectedPeriod = ValueNotifier(MoebooruTimePeriod.day);

  MoebooruPopularRepository get repo => ref.read(moebooruPopularRepoProvider);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PostScope(
          fetcher: (page) => page > 1
              ? TaskEither.of(<Post>[])
              : repo.getPopularPostsRecent(selectedPeriod.value),
          builder: (context, controller, errors) => Column(
            children: [
              PeriodToggleSwitch(
                onToggle: (period) {
                  selectedPeriod.value = period;
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
