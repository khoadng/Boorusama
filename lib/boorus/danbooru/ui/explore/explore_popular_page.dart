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
import 'time_scale_toggle_switch.dart';

class ExplorePopularPage extends ConsumerWidget {
  const ExplorePopularPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.explorePopular,
        ),
        builder: (_) => DanbooruProvider.of(
          context,
          builder: (dcontext) {
            return CustomContextMenuOverlay(
              child: ProviderScope(
                overrides: [
                  timeScaleProvider.overrideWith((ref) => TimeScale.day),
                  dateProvider.overrideWith((ref) => DateTime.now()),
                ],
                child: const ExplorePopularPage(),
              ),
            );
          },
        ),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAndDate = ref.watch(timeAndDateProvider);

    return DanbooruPostScope(
      fetcher: (page) => context
          .read<ExploreRepository>()
          .getPopularPosts(timeAndDate.second, page, timeAndDate.first),
      builder: (context, controller, errors) => _PopularContent(
        controller: controller,
        errors: errors,
      ),
    );
  }
}

class _PopularContent extends ConsumerWidget {
  const _PopularContent({
    required this.controller,
    this.errors,
  });

  final PostGridController<DanbooruPost> controller;
  final BooruError? errors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeAndDate = ref.watch(timeAndDateProvider);

    ref.listen(
      timeAndDateProvider,
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
                title: 'explore.popular'.tr(),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    TimeScaleToggleSwitch(
                      onToggle: (scale) =>
                          ref.read(timeScaleProvider.notifier).state = scale,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: DateTimeSelector(
            onDateChanged: (date) =>
                ref.read(dateProvider.notifier).state = date,
            date: timeAndDate.second,
            scale: timeAndDate.first,
            backgroundColor: Colors.transparent,
          ),
        ),
      ],
    );
  }
}
