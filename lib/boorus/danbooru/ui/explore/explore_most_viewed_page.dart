// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'datetime_selector.dart';

class ExploreMostViewedPage extends ConsumerWidget {
  const ExploreMostViewedPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreMostViewed,
        ),
        builder: (_) => DanbooruProvider.of(
          context,
          builder: (dcontext) {
            return CustomContextMenuOverlay(
              child: ProviderScope(
                overrides: [
                  dateProvider.overrideWith((ref) => DateTime.now()),
                ],
                child: const ExploreMostViewedPage(),
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(dateProvider);

    return DanbooruPostScope(
      fetcher: (page) =>
          context.read<ExploreRepository>().getMostViewedPosts(date),
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
