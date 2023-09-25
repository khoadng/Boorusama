// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/datetime_selector.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'widgets/explores/explore_sliver_app_bar.dart';

class ExploreMostViewedPage extends ConsumerWidget {
  const ExploreMostViewedPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreMostViewed,
        ),
        builder: (_) => CustomContextMenuOverlay(
          child: ProviderScope(
            overrides: [
              dateProvider.overrideWith((ref) => DateTime.now()),
            ],
            child: const ExploreMostViewedPage(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    return DanbooruPostScope(
      fetcher: (page) => page > 1
          ? TaskEither.fromEither(Either.of([]))
          : ref.watch(danbooruExploreRepoProvider).getMostViewedPosts(date),
      builder: (context, controller, errors) => _MostViewedContent(
        controller: controller,
        errors: errors,
      ),
    );
  }
}

class _MostViewedContent extends ConsumerWidget {
  const _MostViewedContent({
    required this.controller,
    this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    ref.listen(
      dateProvider,
      (previous, next) async {
        if (previous != next) {
          // Delay 100ms, this is a hack
          await const Duration(milliseconds: 100).future;
          controller.refresh();
        }
      },
    );

    return Column(
      children: [
        Expanded(
          child: DanbooruInfinitePostList(
            errors: errors,
            controller: controller,
            sliverHeaderBuilder: (context) => [
              ExploreSliverAppBar(
                title: 'explore.most_viewed'.tr(),
              ),
            ],
          ),
        ),
        Container(
          color: context.theme.bottomNavigationBarTheme.backgroundColor,
          child: DateTimeSelector(
            onDateChanged: (date) =>
                ref.read(dateProvider.notifier).state = date,
            date: date,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
