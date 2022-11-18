// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/explore/explore_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/utils.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/widgets/shadow_gradient_overlay.dart';
import 'explore_section.dart';

const double _kMaxHeight = 250;
const _padding = EdgeInsets.symmetric(horizontal: 2);

class ExplorePage extends StatelessWidget {
  const ExplorePage({super.key});

  Widget mapToCarousel(
    BuildContext context,
    ExploreData explore,
  ) {
    return explore.data.isNotEmpty
        ? _ExploreList(
            posts: explore.data,
            onTap: (index) {
              goToDetailPage(
                context: context,
                posts: explore.data,
                initialIndex: index,
                postBloc: explore.bloc,
              );
            },
          )
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
    return BlocBuilder<ExploreBloc, ExploreState>(
      builder: (context, state) {
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
                child: ExploreSection(
                  date: state.popular.date,
                  title: 'explore.popular'.tr(),
                  category: ExploreCategory.popular,
                  builder: (_) => mapToCarousel(context, state.popular),
                ),
              ),
              SliverToBoxAdapter(
                child: ExploreSection(
                  date: state.hot.date,
                  title: 'explore.hot'.tr(),
                  category: ExploreCategory.hot,
                  builder: (_) => mapToCarousel(context, state.hot),
                ),
              ),
              SliverToBoxAdapter(
                child: ExploreSection(
                  date: state.curated.date,
                  title: 'explore.curated'.tr(),
                  category: ExploreCategory.curated,
                  builder: (_) => mapToCarousel(context, state.curated),
                ),
              ),
              SliverToBoxAdapter(
                child: ExploreSection(
                  date: state.mostViewed.date,
                  title: 'explore.most_viewed'.tr(),
                  category: ExploreCategory.mostViewed,
                  builder: (_) => mapToCarousel(context, state.mostViewed),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(
                  height: kBottomNavigationBarHeight + 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExploreList extends StatefulWidget {
  const _ExploreList({
    required this.posts,
    required this.onTap,
  });

  final List<PostData> posts;
  final void Function(int index) onTap;

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
              onTap: () => widget.onTap(index),
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
