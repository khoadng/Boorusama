// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/posts/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags_providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/artist_section.dart';
import 'package:boorusama/boorus/core/widgets/note_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'danbooru_information_section.dart';
import 'danbooru_more_action_button.dart';
import 'danbooru_post_action_toolbar.dart';
import 'danbooru_recommend_artist_list.dart';
import 'danbooru_recommend_character_list.dart';
import 'pool_tiles.dart';
import 'post_stats_tile.dart';
import 'post_tag_list.dart';
import 'related_posts_section.dart';

class DanbooruPostDetailsPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
  });

  final int intitialIndex;
  final List<DanbooruPost> posts;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context, {
    required List<DanbooruPost> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
    bool hero = false,
  }) =>
      MaterialPageRoute(
          builder: (_) => DanbooruProvider(
                builder: (_) => DanbooruPostDetailsPage(
                  intitialIndex: initialIndex,
                  posts: posts,
                  onExit: (page) => scrollController?.scrollToIndex(page),
                ),
              ));

  @override
  ConsumerState<DanbooruPostDetailsPage> createState() =>
      _DanbooruPostDetailsPageState();
}

class _DanbooruPostDetailsPageState
    extends ConsumerState<DanbooruPostDetailsPage>
    with PostDetailsPageMixin<DanbooruPostDetailsPage, DanbooruPost> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !posts[widget.intitialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<DanbooruPost> get posts => widget.posts;

  @override
  int get initialPage => widget.intitialIndex;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.intitialIndex,
      onExit: widget.onExit,
      onPageChanged: onSwiped,
      bottomSheet: (page) {
        return Container(
          decoration: BoxDecoration(
            color: context.theme.scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(
                color: context.theme.dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (posts[page].isVideo)
                ValueListenableBuilder<VideoProgress>(
                  valueListenable: videoProgress,
                  builder: (_, progress, __) =>
                      BooruVideoProgressBar(progress: progress),
                ),
              DanbooruInformationSection(
                post: posts[page],
                showSource: true,
              ),
              DanbooruPostActionToolbar(post: posts[page]),
            ],
          ),
        );
      },
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].thumbnailFromSettings(ref.read(settingsProvider)),
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets =
            _buildWidgets(context, expanded, page, currentPage, ref);
        final artists =
            ref.watch(danbooruPostDetailsArtistProvider(posts[page].id));
        final characters =
            ref.watch(danbooruPostDetailsCharacterProvider(posts[page].id));

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
              RelatedPostsSection(post: posts[page]),
              DanbooruRecommendArtistList(artists: artists),
              DanbooruRecommendCharacterList(characters: characters),
            ],
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (page, expanded) {
        final noteState = ref.watch(notesControllerProvider(posts[page]));
        final post = posts[page];

        return [
          NoteActionButton(
            post: post,
            showDownload: !expanded && noteState.notes.isEmpty,
            enableNotes: noteState.enableNotes,
            onDownload: () =>
                ref.read(notesControllerProvider(post).notifier).load(),
            onToggleNotes: () => ref
                .read(notesControllerProvider(post).notifier)
                .toggleNoteVisibility(),
          ),
          DanbooruMoreActionButton(
            onToggleSlideShow: controller.toggleSlideShow,
            post: post,
          ),
        ];
      },
      onExpanded: (currentPage) {
        final post = posts[currentPage];

        post.loadDetailsFrom(ref);
      },
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
    WidgetRef ref,
  ) {
    final post = posts[page];
    final noteState = ref.watch(notesControllerProvider(post));
    final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    final tags = post.extractTagDetails();
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = PostMedia(
      post: post,
      imageUrl: post.thumbnailFromSettings(ref.read(settingsProvider)),
      // Prevent placeholder image from showing when first loaded a post with translated image
      placeholderImageUrl:
          currentPage == widget.intitialIndex && post.isTranslated
              ? null
              : post.thumbnailImageUrl,
      onImageTap: onImageTap,
      onCurrentVideoPositionChanged: onCurrentPositionChanged,
      onVideoVisibilityChanged: onVisibilityChanged,
      imageOverlayBuilder: (constraints) =>
          noteOverlayBuilderDelegate(constraints, post, noteState),
      useHero: page == currentPage,
      onImageZoomUpdated: onZoomUpdated,
    );

    return [
      if (!expandedOnCurrentPage)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else if (post.isVideo)
        BooruImage(
          imageUrl: post.videoThumbnailUrl,
          fit: BoxFit.contain,
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        PoolTiles(pools: pools),
        DanbooruInformationSection(
          post: post,
          showSource: true,
        ),
        const Divider(height: 8, thickness: 1),
        RepaintBoundary(
          child: DanbooruPostActionToolbar(post: post),
        ),
        const Divider(height: 8, thickness: 1),
        DanbooruArtistSection(post: post),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: DanbooruPostStatsTile(post: post),
        ),
        const Divider(height: 8, thickness: 1),
        TagsTile(
            tags: tags
                .where((e) => e.postId == post.id)
                .map((e) => e.name)
                .toList()),
        FileDetailsSection(post: post),
        const Divider(height: 8, thickness: 1),
      ],
    ];
  }
}

class DanbooruPostStatsTile extends ConsumerWidget {
  const DanbooruPostStatsTile({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comments = ref.watch(danbooruCommentProvider(post.id));

    return RepaintBoundary(
      child: PostStatsTile(
        post: post,
        totalComments: comments?.length ?? 0,
      ),
    );
  }
}

class DanbooruArtistSection extends ConsumerWidget {
  const DanbooruArtistSection({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentary = ref.watch(danbooruArtistCommentaryProvider(post.id));

    return ArtistSection(
      commentary: commentary,
      artistTags: post.artistTags,
      source: post.source,
    );
  }
}

// ignore: prefer-single-widget-per-file
class TagsTile extends ConsumerWidget {
  const TagsTile({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) =>
            value ? ref.read(tagsProvider.notifier).load(tags) : null,
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
