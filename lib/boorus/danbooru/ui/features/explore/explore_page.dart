// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags_bloc.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'explore_carousel.dart';
import 'explore_section.dart';

class ExplorePage extends StatelessWidget {
  const ExplorePage({Key? key}) : super(key: key);

  Widget mapStateToCarousel(
    BuildContext context,
    PostState state,
  ) {
    if (state.status == LoadStatus.success) {
      if (state.posts.isEmpty) return const CarouselPlaceholder();
      return ExploreCarousel(
        posts: state.posts.map((e) => e.post).toList(),
        onTap: (index) {
          AppRouter.router.navigateTo(
            context,
            '/post/detail',
            routeSettings: RouteSettings(
              arguments: [
                state.posts,
                index,
              ],
            ),
          );
        },
      );
    } else if (state.status == LoadStatus.failure) {
      return const Center(
        child: Text('Something went wrong'),
      );
    } else {
      return const CarouselPlaceholder();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlacklistedTagsBloc, BlacklistedTagsState>(
      builder: (context, blacklistedTagsState) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
            final popularBloc = PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: ExplorePreviewFetcher.now(
                      category: ExploreCategory.popular)));

            final hotBloc = PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: ExplorePreviewFetcher.now(
                      category: ExploreCategory.hot)));

            final curatedBloc = PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: ExplorePreviewFetcher.now(
                      category: ExploreCategory.curated)));

            final mostViewedBloc = PostBloc.of(context)
              ..add(PostRefreshed(
                  fetcher: ExplorePreviewFetcher.now(
                      category: ExploreCategory.mostViewed)));

            return Padding(
              padding: Screen.of(context).size == ScreenSize.small
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 8),
              child: CustomScrollView(
                primary: false,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: MediaQuery.of(context).viewPadding.top,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocProvider.value(
                      value: popularBloc,
                      child: ExploreSection(
                        title: 'explore.popular'.tr(),
                        category: ExploreCategory.popular,
                        builder: (_) => BlocBuilder<PostBloc, PostState>(
                          builder: mapStateToCarousel,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocProvider.value(
                      value: hotBloc,
                      child: ExploreSection(
                        title: 'explore.hot'.tr(),
                        category: ExploreCategory.hot,
                        builder: (_) => BlocBuilder<PostBloc, PostState>(
                          builder: mapStateToCarousel,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocProvider.value(
                      value: curatedBloc,
                      child: ExploreSection(
                        title: 'explore.curated'.tr(),
                        category: ExploreCategory.curated,
                        builder: (_) => BlocBuilder<PostBloc, PostState>(
                          builder: mapStateToCarousel,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: BlocProvider.value(
                      value: mostViewedBloc,
                      child: ExploreSection(
                        title: 'explore.most_viewed'.tr(),
                        category: ExploreCategory.mostViewed,
                        builder: (_) => BlocBuilder<PostBloc, PostState>(
                          builder: mapStateToCarousel,
                        ),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(
                      height: kBottomNavigationBarHeight + 10,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
