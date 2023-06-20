// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/posts/recommend_posts.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/pages/post_details/artist_section.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/feats/artists/e621_artist_provider.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/popular/e621_post_tag_list.dart';
import 'package:boorusama/boorus/e621/router.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'e621_information_section.dart';
import 'e621_post_action_toolbar.dart';

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
          builder: (_) => E621Provider(
                builder: (_) => E621PostDetailsPage(
                  intitialIndex: initialIndex,
                  posts: posts,
                  onExit: (page) => scrollController?.scrollToIndex(page),
                ),
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
                  builder: (_, progress, __) =>
                      BooruVideoProgressBar(progress: progress),
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
                Builder(
                  builder: (context) {
                    final artist = posts[page].artistTags.firstOrNull;
                    return ref.watch(e621ArtistPostsProvider(artist)).maybeWhen(
                          data: (posts) => RecommendPosts(
                            title: artist?.replaceAll('_', ' ') ?? '',
                            items: posts.take(30).toList(),
                            onTap: (index) => goToE621DetailsPage(
                              context: context,
                              posts: posts,
                              initialPage: index,
                            ),
                            onHeaderTap: () =>
                                goToE621ArtistPage(context, artist ?? ''),
                            imageUrl: (item) => item.thumbnailFromSettings(
                              ref.read(settingsProvider),
                            ),
                          ),
                          orElse: () => const SliverSizedBox.shrink(),
                        );
                  },
                ),
              // RecommendCharacterList(
              //   onHeaderTap: (index) =>
              //       goToCharacterPage(context, characters[index].tag),
              //   onTap: (recommendIndex, postIndex) => goToDetailPage(
              //     context: context,
              //     posts: characters[recommendIndex].posts,
              //     initialIndex: postIndex,
              //     hero: false,
              //   ),
              //   recommends: characters,
              //   imageUrl: (item) => item.url360x360,
              // ),
            ],
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (page, expanded) {
        // final noteState =
        //     ref.watch(danbooruPostDetailsNoteProvider(posts[page]));

        return [
          //FIXME: add note back
          // Builder(builder: (_) {
          //   final theme = ref.watch(themeProvider);

          //   if (!posts[page].isTranslated) {
          //     return const SizedBox.shrink();
          //   }

          //   if (!expanded && noteState.notes.isEmpty) {
          //     return ElevatedButton.icon(
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor:
          //             context.colorScheme.background.withOpacity(0.8),
          //         padding: const EdgeInsets.all(4),
          //       ),
          //       icon: const Icon(Icons.download_rounded),
          //       label: const Text('Notes'),
          //       onPressed: () =>
          //           ref.read(danbooruNoteProvider(posts[page]).notifier).load(),
          //     );
          //   }

          //   return CircularIconButton(
          //     icon: noteState.enableNotes
          //         ? Padding(
          //             padding: const EdgeInsets.all(3),
          //             child: FaIcon(
          //               FontAwesomeIcons.eyeSlash,
          //               size: 18,
          //               color: theme == ThemeMode.light
          //                   ? context.colorScheme.onPrimary
          //                   : null,
          //             ),
          //           )
          //         : Padding(
          //             padding: const EdgeInsets.all(4),
          //             child: FaIcon(
          //               FontAwesomeIcons.eye,
          //               size: 18,
          //               color: theme == ThemeMode.light
          //                   ? context.colorScheme.onPrimary
          //                   : null,
          //             ),
          //           ),
          //     onPressed: () => ref
          //         .read(danbooruPostDetailsNoteProvider(posts[page]).notifier)
          //         .toggleNoteVisibility(),
          //   );
          // }),
          GeneralMoreActionButton(
            post: posts[page],
          ),
        ];
      },
      onExpanded: (currentPage) {
        // final post = posts[currentPage];

        //FIXME: show load details
        // post.loadDetailsFrom(ref);
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
    final theme = ref.watch(themeProvider);
    final post = posts[page];
    // final noteState = ref.watch(danbooruPostDetailsNoteProvider(post));
    // final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    // final tags = ref.watch(danbooruPostDetailsTagsProvider(post.id));
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? post.format == 'webm'
            ? EmbeddedWebViewWebm(
                url: post.originalImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
                backgroundColor:
                    theme == ThemeMode.light ? Colors.white : Colors.black,
              )
            : BooruVideo(
                url: post.videoUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
        : InteractiveBooruImage(
            useHero: page == currentPage,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: post.thumbnailFromSettings(ref.read(settingsProvider)),
            // Prevent placeholder image from showing when first loaded a post with translated image
            placeholderImageUrl:
                currentPage == widget.intitialIndex && post.isTranslated
                    ? null
                    : post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: ref.watch(previewImageCacheManagerProvider),
            imageOverlayBuilder: (constraints) => [
              // if (noteState.enableNotes)
              //   ...noteState.notes
              //       .map((e) => e.adjustNoteCoordFor(
              //             posts[page],
              //             widthConstraint: constraints.maxWidth,
              //             heightConstraint: constraints.maxHeight,
              //           ))
              //       .map((e) => PostNote(
              //             coordinate: e.coordinate,
              //             content: e.content,
              //           )),
            ],
            width: post.width,
            height: post.height,
            onZoomUpdated: onZoomUpdated,
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
          imageUrl: post.thumbnailFromSettings(ref.watch(settingsProvider)),
          fit: BoxFit.contain,
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
      artistCommentary: ArtistCommentary(
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
