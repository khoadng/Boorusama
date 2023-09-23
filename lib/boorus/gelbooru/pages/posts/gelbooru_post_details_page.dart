// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts.dart';
import 'package:boorusama/boorus/gelbooru/pages/posts/gelbooru_recommend_artist_list.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class GelbooruPostDetailsPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.onExit,
    this.hasDetailsTagList = true,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int page) onExit;
  final bool hasDetailsTagList;

  static MaterialPageRoute routeOf({
    required BooruConfig booruConfig,
    required Settings settings,
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
  }) {
    return MaterialPageRoute(
      builder: (_) => GelbooruPostDetailsPage(
        posts: posts,
        initialIndex: initialIndex,
        onExit: (page) => scrollController?.scrollToIndex(page),
        hasDetailsTagList: booruConfig.booruType.supportTagDetails,
      ),
    );
  }

  @override
  ConsumerState<GelbooruPostDetailsPage> createState() =>
      _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailsPage>
    with PostDetailsPageMixin<GelbooruPostDetailsPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<Post> get posts => widget.posts;

  @override
  int get initialPage => widget.initialIndex;

  @override
  Widget build(BuildContext context) {
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: onSwiped,
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder<VideoProgress>(
              valueListenable: videoProgress,
              builder: (_, progress, __) => BooruVideoProgressBar(
                progress: progress,
                onSeek: (position) => onVideoSeekTo(position, page),
              ),
            ),
          GelbooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailImageUrl,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets = _buildWidgets(
            context, expanded, page, currentPage, ref, booruConfig);
        final artists =
            ref.watch(booruPostDetailsArtistProvider(posts[page].id));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomScrollView(
            physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
            controller: PageContentScrollController.of(context),
            slivers: [
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => widgets[index],
                  childCount: widgets.length,
                ),
              ),
              GelbooruRecommendedArtistList(artists: artists)
            ],
          ),
        );
      },
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page, expanded) => [
        GeneralMoreActionButton(post: widget.posts[page]),
      ],
      onExpanded: widget.hasDetailsTagList
          ? (currentPage) => ref.read(tagsProvider(booruConfig).notifier).load(
                posts[currentPage].tags,
                onSuccess: (tags) {
                  if (!mounted) return;
                  posts[currentPage].loadArtistPostsFrom(ref, tags);
                },
              )
          : null,
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
    BooruConfig booruConfig,
  ) {
    final post = posts[page];
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = PostMedia(
      inFocus: !expanded && page == currentPage,
      post: post,
      imageUrl: post.thumbnailFromSettings(ref.read(settingsProvider)),
      placeholderImageUrl: post.thumbnailImageUrl,
      onImageTap: onImageTap,
      onCurrentVideoPositionChanged: onCurrentPositionChanged,
      onVideoVisibilityChanged: onVisibilityChanged,
      useHero: page == currentPage,
      onImageZoomUpdated: onZoomUpdated,
      onVideoPlayerCreated: (controller) =>
          onVideoPlayerCreated(controller, page),
      onWebmVideoPlayerCreated: (controller) =>
          onWebmVideoPlayerCreated(controller, page),
      autoPlay: true,
    );

    return [
      if (!expandedOnCurrentPage)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        if (widget.hasDetailsTagList)
          TagsTile(
            tags: ref.watch(tagsProvider(booruConfig)),
            post: post,
            onTagTap: (tag) =>
                goToGelbooruSearchPage(ref, context, tag: tag.rawName),
          )
        else
          BasicTagList(
            tags: post.tags,
            onTap: (tag) => goToGelbooruSearchPage(ref, context, tag: tag),
          ),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(
          post: post,
        ),
        post.source.whenWeb(
          (source) => SourceSection(source: source),
          () => const SizedBox.shrink(),
        ),
      ],
    ];
  }
}
