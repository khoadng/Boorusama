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
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/utils.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
import 'explore_section.dart';

const double _kMaxHeight = 250;
const _padding = EdgeInsets.symmetric(horizontal: 2);

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Widget mapStateToCarousel(
    BuildContext context,
    PostState state,
  ) {
    return state.status == LoadStatus.success && state.posts.isNotEmpty
        ? _ExploreList(posts: state.posts.take(20).toList())
        : SizedBox(
            height: _kMaxHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 20,
              itemBuilder: (context, index) => Padding(
                padding: _padding,
                child: createRandomPlaceholderContainer(context),
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BlacklistedTagsBloc, BlacklistedTagsState>(
      builder: (context, blacklistedTagsState) {
        return BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settingsState) {
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
                    child: BlocProvider(
                      create: (context) => PostBloc.of(context)
                        ..add(PostRefreshed(
                          fetcher: ExplorePreviewFetcher.now(
                            category: ExploreCategory.popular,
                            exploreRepository:
                                context.read<ExploreRepository>(),
                          ),
                        )),
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
                    child: BlocProvider(
                      create: (context) => PostBloc.of(context)
                        ..add(PostRefreshed(
                          fetcher: ExplorePreviewFetcher.now(
                            category: ExploreCategory.hot,
                            exploreRepository:
                                context.read<ExploreRepository>(),
                          ),
                        )),
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
                    child: BlocProvider(
                      create: (context) => PostBloc.of(context)
                        ..add(PostRefreshed(
                          fetcher: ExplorePreviewFetcher.now(
                            category: ExploreCategory.curated,
                            exploreRepository:
                                context.read<ExploreRepository>(),
                          ),
                        )),
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
                    child: BlocProvider(
                      create: (context) => PostBloc.of(context)
                        ..add(PostRefreshed(
                          fetcher: ExplorePreviewFetcher.now(
                            category: ExploreCategory.mostViewed,
                            exploreRepository:
                                context.read<ExploreRepository>(),
                          ),
                        )),
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
                      height: kBottomNavigationBarHeight + 60,
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

class _ExploreList extends StatefulWidget {
  const _ExploreList({
    required this.posts,
  });

  final List<PostData> posts;

  @override
  State<_ExploreList> createState() => _ExploreListState();
}

class _ExploreListState extends State<_ExploreList> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _kMaxHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final posts = widget.posts;
          final post = posts[index].post;

          return Padding(
            padding: _padding,
            child: GestureDetector(
              onTap: () {
                goToDetailPage(
                  context: context,
                  posts: widget.posts,
                  initialIndex: index,
                  postBloc: context.read<PostBloc>(),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  BooruImage(
                    aspectRatio: post.aspectRatio,
                    imageUrl: post.isAnimated
                        ? post.previewImageUrl
                        : post.normalImageUrl,
                    placeholderUrl: post.previewImageUrl,
                  ),
                  Positioned.fill(
                    child: ShadowGradientOverlay(
                      alignment: Alignment.bottomCenter,
                      colors: <Color>[
                        const Color(0xC2000000),
                        Colors.black12.withOpacity(0),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 5,
                    bottom: 1,
                    child: Text(
                      '${index + 1}',
                      style: Theme.of(context)
                          .textTheme
                          .headline2!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: widget.posts.length,
      ),
    );
  }
}
