// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/artist_section.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/note_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/popular/e621_post_tag_list.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'e621_information_section.dart';
import 'e621_post_action_toolbar.dart';
import 'e621_recommended_artist_list.dart';

class E621PostDetailsPage extends ConsumerStatefulWidget {
  const E621PostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onExit,
  });

  final int intitialIndex;
  final List<E621Post> posts;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context, {
    required List<E621Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
    bool hero = false,
  }) =>
      MaterialPageRoute(
          builder: (_) => E621PostDetailsPage(
                intitialIndex: initialIndex,
                posts: posts,
                onExit: (page) => scrollController?.scrollToIndex(page),
              ));

  @override
  ConsumerState<E621PostDetailsPage> createState() =>
      _E621PostDetailsPageState();
}

class _E621PostDetailsPageState extends ConsumerState<E621PostDetailsPage>
    with PostDetailsPageMixin<E621PostDetailsPage, E621Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !posts[widget.intitialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => (page) => ref
      .read(postShareProvider(posts[page]).notifier)
      .updateInformation(posts[page]);

  @override
  List<E621Post> get posts => widget.posts;

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
            color: context.theme.scaffoldBackgroundColor.withOpacity(0.8),
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
                  builder: (_, progress, __) => BooruVideoProgressBar(
                    progress: progress,
                    onSeek: (position) => onVideoSeekTo(position, page),
                  ),
                ),
              E621InformationSection(
                post: posts[page],
                showSource: true,
              ),
              E621PostActionToolbar(post: posts[page]),
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

        // final characters =
        //     ref.watch(danbooruPostDetailsCharacterProvider(posts[page].id));

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
              // const RelatedPostsSection(),
              if (expanded && page == currentPage)
                E621RecommendedArtistList(post: posts[page]),
            ],
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (page, expanded) {
        final post = posts[page];
        final noteState = ref.watch(notesControllerProvider(post));

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
          GeneralMoreActionButton(
            post: post,
          ),
        ];
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
    // final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    // final tags = ref.watch(danbooruPostDetailsTagsProvider(post.id));
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = PostMedia(
      inFocus: !expanded && page == currentPage,
      post: post,
      imageUrl: post.sampleImageUrl,
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
        E621InformationSection(
          post: post,
          showSource: true,
        ),
        const Divider(height: 8, thickness: 1),
        RepaintBoundary(
          child: E621PostActionToolbar(post: post),
        ),
        const Divider(height: 8, thickness: 1),
        E621ArtistSection(post: post),
        //FIXME: implement stats tile
        // Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 8),
        //   child: DanbooruPostStatsTile(post: post),
        // ),
        const Divider(height: 8, thickness: 1),
        E621TagsTile(post: post),
        FileDetailsSection(post: post),
        const Divider(height: 8, thickness: 1),
      ],
    ];
  }
}

// class DanbooruPostStatsTile extends ConsumerWidget {
//   const DanbooruPostStatsTile({
//     super.key,
//     required this.post,
//   });

//   final DanbooruPost post;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final comments = ref.watch(danbooruCommentProvider(post.id));

//     return RepaintBoundary(
//       child: PostStatsTile(
//         post: post,
//         totalComments: comments?.length ?? 0,
//       ),
//     );
//   }
// }

class E621ArtistSection extends ConsumerWidget {
  const E621ArtistSection({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentary = post.description;

    return ArtistSection(
      //FIXME: shouldn't use danbooru's artist section, should separate it
      commentary: ArtistCommentary(
        originalTitle: '',
        originalDescription: commentary,
        translatedTitle: '',
        translatedDescription: '',
      ),
      artistTags: post.artistTags,
      source: post.source,
    );
  }
}

class E621TagsTile extends ConsumerWidget {
  const E621TagsTile({
    super.key,
    required this.post,
  });

  final E621Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Theme(
      data: context.theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${post.tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: E621PostTagList(post: post),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
