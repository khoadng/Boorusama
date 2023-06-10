// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/providers.dart';
import 'package:boorusama/boorus/core/feats/tags/tags_providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'artist_section.dart';
import 'danbooru_more_action_button.dart';
import 'danbooru_post_action_toolbar.dart';
import 'information_section.dart';
import 'pool_tiles.dart';
import 'post_note.dart';
import 'post_stats_tile.dart';
import 'post_tag_list.dart';
import 'related_posts_section.dart';

final danbooruPostProvider = Provider<DanbooruPost>((ref) {
  throw UnimplementedError();
});

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
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
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
              InformationSection(
                post: posts[page],
                showSource: true,
              ),
              DanbooruPostActionToolbar(post: posts[page]),
            ],
          ),
        );
      },
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].isGif
            ? posts[page].urlOriginal
            : posts[page].url720x720,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets =
            _buildWidgets(context, expanded, page, currentPage, ref);
        final artists =
            ref.watch(danbooruPostDetailsArtistProvider(posts[page].id));
        final characters =
            ref.watch(danbooruPostDetailsCharacterProvider(posts[page].id));

        return ProviderScope(
          overrides: [
            danbooruPostProvider.overrideWithValue(posts[page]),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: CustomScrollView(
              physics:
                  enableSwipe ? null : const NeverScrollableScrollPhysics(),
              controller: PageContentScrollController.of(context),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => widgets[index],
                    childCount: widgets.length,
                  ),
                ),
                const RelatedPostsSection(),
                RecommendArtistList(
                  onTap: (recommendIndex, postIndex) => goToDetailPage(
                    context: context,
                    posts: artists[recommendIndex].posts,
                    initialIndex: postIndex,
                  ),
                  onHeaderTap: (index) =>
                      goToArtistPage(context, artists[index].tag),
                  recommends: artists,
                  imageUrl: (item) => item.url360x360,
                ),
                RecommendCharacterList(
                  onHeaderTap: (index) =>
                      goToCharacterPage(context, characters[index].tag),
                  onTap: (recommendIndex, postIndex) => goToDetailPage(
                    context: context,
                    posts: characters[recommendIndex].posts,
                    initialIndex: postIndex,
                    hero: false,
                  ),
                  recommends: characters,
                  imageUrl: (item) => item.url360x360,
                ),
              ],
            ),
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (page, expanded) {
        final noteState =
            ref.watch(danbooruPostDetailsNoteProvider(posts[page]));

        return [
          Builder(builder: (_) {
            final theme = ref.watch(themeProvider);

            if (!posts[page].isTranslated) {
              return const SizedBox.shrink();
            }

            if (!expanded && noteState.notes.isEmpty) {
              return ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.background.withOpacity(0.8),
                  padding: const EdgeInsets.all(4),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Notes'),
                onPressed: () =>
                    ref.read(danbooruNoteProvider(posts[page]).notifier).load(),
              );
            }

            return CircularIconButton(
              icon: noteState.enableNotes
                  ? Padding(
                      padding: const EdgeInsets.all(3),
                      child: FaIcon(
                        FontAwesomeIcons.eyeSlash,
                        size: 18,
                        color: theme == ThemeMode.light
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(4),
                      child: FaIcon(
                        FontAwesomeIcons.eye,
                        size: 18,
                        color: theme == ThemeMode.light
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
              onPressed: () => ref
                  .read(danbooruPostDetailsNoteProvider(posts[page]).notifier)
                  .toggleNoteVisibility(),
            );
          }),
          DanbooruMoreActionButton(
            onToggleSlideShow: controller.toggleSlideShow,
            post: posts[page],
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
    final theme = ref.watch(themeProvider);
    final post = posts[page];
    final noteState = ref.watch(danbooruPostDetailsNoteProvider(post));
    final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    final tags = ref.watch(danbooruPostDetailsTagsProvider(post.id));
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
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
            imageUrl: post.isGif
                ? post.urlOriginal
                : post.thumbnailFromSettings(ref.read(settingsProvider)),
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: ref.watch(previewImageCacheManagerProvider),
            imageOverlayBuilder: (constraints) => [
              if (noteState.enableNotes)
                ...noteState.notes
                    .map((e) => e.adjustNoteCoordFor(
                          posts[page],
                          widthConstraint: constraints.maxWidth,
                          heightConstraint: constraints.maxHeight,
                        ))
                    .map((e) => PostNote(
                          coordinate: e.coordinate,
                          content: e.content,
                        )),
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
          imageUrl: post.videoThumbnailUrl,
          fit: BoxFit.contain,
        )
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        PoolTiles(pools: pools),
        InformationSection(
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
      artistCommentary: commentary,
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
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
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
