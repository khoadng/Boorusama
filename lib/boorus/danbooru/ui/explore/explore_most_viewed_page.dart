// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explores/explore_utils.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router_page_constant.dart';
import 'package:boorusama/boorus/danbooru/ui/explore/explore_sliver_app_bar.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/ui/custom_context_menu_overlay.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
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

class _ExploreDetailPageState extends State<ExploreMostViewedPage>
    with DanbooruPostTransformMixin, DanbooruPostServiceProviderMixin {
  late final _controller = PostGridController<DanbooruPost>(
    fetcher: (_) => context
        .read<ExploreRepository>()
        .getMostViewedPosts(exploreDetails.value.date)
        .then(transform),
    refresher: () => context
        .read<ExploreRepository>()
        .getMostViewedPosts(exploreDetails.value.date)
        .then(transform),
  );

  late final exploreDetails = ValueNotifier(
    ExploreDetailsData(
      scale: TimeScale.day,
      date: DateTime.now(),
      category: ExploreCategory.mostViewed,
    ),
  );

  @override
  void initState() {
    super.initState();
    exploreDetails.addListener(_onExploreDetailsChanged);
  }

  @override
  void dispose() {
    super.dispose();
    exploreDetails.removeListener(_onExploreDetailsChanged);
    _controller.dispose();
  }

  void _onExploreDetailsChanged() {
    _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: DanbooruInfinitePostList2(
            controller: _controller,
            sliverHeaderBuilder: (context) => [
              ExploreSliverAppBar(
                title: 'explore.most_viewed'.tr(),
              ),
            ],
          ),
        ),
        Container(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: ValueListenableBuilder<ExploreDetailsData>(
            valueListenable: exploreDetails,
            builder: (_, data, __) => DateTimeSelector(
              onDateChanged: (date) => exploreDetails.value =
                  exploreDetails.value.copyWith(date: date),
              date: data.date,
              scale: data.scale,
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}
