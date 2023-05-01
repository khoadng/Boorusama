// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores/explore_utils.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'datetime_selector.dart';

class ExploreMostViewedPage extends StatefulWidget {
  const ExploreMostViewedPage({
    super.key,
  });

  static MaterialPageRoute routeOf(BuildContext context) => MaterialPageRoute(
        settings: const RouteSettings(
          name: RouterPageConstant.exploreMostViewed,
        ),
        builder: (_) => BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
          builder: (_, state) {
            return DanbooruProvider.of(
              context,
              booru: state.booru!,
              builder: (dcontext) {
                return const CustomContextMenuOverlay(
                  child: ExploreMostViewedPage(),
                );
              },
            );
          },
        ),
      );

  @override
  State<ExploreMostViewedPage> createState() => _ExploreDetailPageState();
}

class _ExploreDetailPageState extends State<ExploreMostViewedPage> {
  late final exploreDetails = ValueNotifier(
    ExploreDetailsData(
      scale: TimeScale.day,
      date: DateTime.now(),
      category: ExploreCategory.mostViewed,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ExploreDetailsData>(
      valueListenable: exploreDetails,
      builder: (_, explore, __) => DanbooruPostScope(
        fetcher: (page) =>
            context.read<ExploreRepository>().getMostViewedPosts(explore.date),
        builder: (context, controller, errors) => Column(
          children: [
            Expanded(
              child: DanbooruInfinitePostList(
                errors: errors,
                controller: controller,
                sliverHeaderBuilder: (context) => [
                  ExploreSliverAppBar(
                    title: 'explore.popular'.tr(),
                  ),
                ],
              ),
            ),
            Container(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              child: DateTimeSelector(
                onDateChanged: (date) {
                  exploreDetails.value =
                      exploreDetails.value.copyWith(date: date);
                  controller.refresh();
                },
                date: explore.date,
                scale: explore.scale,
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
