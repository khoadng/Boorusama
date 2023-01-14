// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/models/parent_child_data.dart';
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/parent_child_post_page.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/settings/settings.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
import 'file_details_section.dart';
import 'information_section.dart';
import 'parent_child_tile.dart';
import 'pool_tiles.dart';
import 'post_action_toolbar.dart';
import 'post_info.dart';
import 'post_media_item.dart';
import 'post_stats_tile.dart';
import 'post_tag_list.dart';
import 'recommend_artist_list.dart';
import 'recommend_character_list.dart';

class PostSlider extends StatefulWidget {
  const PostSlider({
    super.key,
    required this.posts,
    required this.imagePath,
  });

  final List<PostData> posts;
  final ValueNotifier<String?> imagePath;

  @override
  State<PostSlider> createState() => _PostSliderState();
}

class _PostSliderState extends State<PostSlider> {
  var enableSwipe = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PostDetailBloc>().state;

    return CarouselSlider.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index, realIndex) {
        final media = PostMediaItem(
          //TODO: this is used to preload image between page
          post: widget.posts[index].post,
          onCached: (path) => widget.imagePath.value = path,
          enableNotes: state.enableNotes,
          notes: state.currentPost.notes,
          previewCacheManager: context.read<PreviewImageCacheManager>(),
          onTap: () => context
              .read<PostDetailBloc>()
              .add(PostDetailOverlayVisibilityChanged(
                enableOverlay: !state.enableOverlay,
              )),
          onZoomUpdated: (zoom) {
            final swipe = !zoom;
            if (swipe != enableSwipe) {
              setState(() {
                enableSwipe = swipe;
              });
            }
          },
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: state.enableSlideShow || state.fullScreen
                ? SafeArea(
                    child: Center(
                      child: media,
                    ),
                  )
                : BlocBuilder<SettingsCubit, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.settings.actionBarDisplayBehavior !=
                        current.settings.actionBarDisplayBehavior,
                    builder: (context, settingsState) {
                      return Stack(
                        children: [
                          if (Screen.of(context).size != ScreenSize.small &&
                              !state.currentPost.post.isVideo)
                            Center(
                              child: media,
                            )
                          else
                            _CarouselContent(
                              media: media,
                              imagePath: widget.imagePath,
                              actionBarDisplayBehavior: settingsState
                                  .settings.actionBarDisplayBehavior,
                              post: state.currentPost,
                              preloadPost: widget.posts[index].post,
                              key: ValueKey(state.currentIndex),
                              recommends: state.recommends,
                              pools: widget.posts[index].pools,
                            ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
      options: CarouselOptions(
        scrollPhysics: enableSwipe
            ? const DetailPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        onPageChanged: (index, reason) {
          context
              .read<SliverPostGridBloc>()
              .add(SliverPostGridItemChanged(index: index));

          context
              .read<PostDetailBloc>()
              .add(PostDetailIndexChanged(index: index));
        },
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        initialPage: state.currentIndex,
        autoPlay: state.enableSlideShow,
        autoPlayAnimationDuration: state.slideShowConfig.skipAnimation
            ? const Duration(microseconds: 1)
            : const Duration(milliseconds: 600),
        autoPlayInterval:
            Duration(seconds: state.slideShowConfig.interval.toInt()),
      ),
    );
  }
}

class DetailPageViewScrollPhysics extends ScrollPhysics {
  const DetailPageViewScrollPhysics({super.parent});

  @override
  DetailPageViewScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return DetailPageViewScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  SpringDescription get spring => const SpringDescription(
        mass: 80,
        stiffness: 100,
        damping: 1,
      );
}

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    super.key,
    required this.media,
    required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.post,
    required this.preloadPost,
    required this.recommends,
    required this.pools,
  });

  final PostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final PostData post;
  final Post preloadPost;
  final List<Pool> pools;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final List<Recommend> recommends;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  Post get post => widget.post.post;

  @override
  Widget build(BuildContext context) {
    final screenSize = Screen.of(context).size;

    return BlocProvider(
      create: (context) =>
          PoolFromPostIdBloc(poolRepository: context.read<PoolRepository>())
            ..add(PoolFromPostIdRequested(postId: post.id)),
      child: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                RepaintBoundary(child: widget.media),
                if (screenSize == ScreenSize.small) ...[
                  PoolTiles(pools: widget.pools),
                  // BlocBuilder<PoolFromPostIdBloc, AsyncLoadState<List<Pool>>>(
                  //   builder: (context, state) {
                  //     return state.status == LoadStatus.success
                  //         ? PoolTiles(pools: state.data!)
                  //         : const SizedBox.shrink();
                  //   },
                  // ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InformationSection(post: widget.preloadPost),
                      const Divider(height: 8, thickness: 1),
                      if (widget.actionBarDisplayBehavior ==
                          ActionBarDisplayBehavior.scrolling) ...[
                        RepaintBoundary(
                          child: ActionBar(
                            imagePath: widget.imagePath,
                            postData: widget.post,
                          ),
                        ),
                        const Divider(height: 8, thickness: 1),
                      ],
                      ArtistSection(post: widget.preloadPost),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child:
                            RepaintBoundary(child: PostStatsTile(post: post)),
                      ),
                      if (widget.preloadPost.hasParentOrChildren)
                        _ParentChildTile(post: widget.preloadPost),
                      if (!widget.preloadPost.hasParentOrChildren)
                        const Divider(height: 8, thickness: 1),
                      TagsTile(post: post),
                      const Divider(height: 8, thickness: 1),
                      FileDetailsSection(
                        post: post,
                      ),
                      const Divider(height: 8, thickness: 1),
                      RecommendArtistList(
                        recommends: widget.recommends
                            .where((element) =>
                                element.type == RecommendType.artist)
                            .toList(),
                      ),
                      RecommendCharacterList(
                        recommends: widget.recommends
                            .where((element) =>
                                element.type == RecommendType.character)
                            .toList(),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((PostDetailBloc bloc) =>
        bloc.state.tags.where((e) => e.postId == post.id).toList());

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) => value
            ? context.read<TagBloc>().add(TagFetched(tags: post.tags))
            : null,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: PostTagList(),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ParentChildTile extends StatelessWidget {
  const _ParentChildTile({
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ParentChildTile(
      data: getParentChildData(post),
      onTap: (data) => showBarModalBottomSheet(
        context: context,
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => PostBloc.of(context)
                ..add(PostRefreshed(
                  tag: data.tagQueryForDataFetching,
                  fetcher: SearchedPostFetcher.fromTags(
                    data.tagQueryForDataFetching,
                  ),
                )),
            ),
          ],
          child: ParentChildPostPage(
            parentPostId: data.parentId,
          ),
        ),
      ),
    );
  }
}

// ignore: prefer-single-widget-per-file
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.imagePath,
    required this.postData,
  });

  final ValueNotifier<String?> imagePath;
  final PostData postData;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: imagePath,
      builder: (context, value, child) => PostActionToolbar(
        postData: postData,
        imagePath: value,
      ),
    );
  }
}
