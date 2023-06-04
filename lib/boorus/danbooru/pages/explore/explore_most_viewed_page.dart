// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/pages/custom_context_menu_overlay.dart';
import 'package:boorusama/boorus/core/pages/post_grid_controller.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/explores/explore_provider.dart';
import 'package:boorusama/boorus/danbooru/features/posts/models/danbooru_post.dart';
import 'package:boorusama/boorus/danbooru/pages/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/functional.dart';
import 'datetime_selector.dart';

class ExploreMostViewedPage extends ConsumerWidget {
  const ExploreMostViewedPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreMostViewed,
        ),
        builder: (_) => DanbooruProvider(
          builder: (_) => CustomContextMenuOverlay(
            child: ProviderScope(
              overrides: [
                dateProvider.overrideWith((ref) => DateTime.now()),
              ],
              child: const ExploreMostViewedPage(),
            ),
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
      (previous, next) {
        if (previous != next) {
          // Delay 100ms, this is a hack
          Future.delayed(const Duration(milliseconds: 100), () {
            controller.refresh();
          });
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
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
