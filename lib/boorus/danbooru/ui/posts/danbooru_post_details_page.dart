// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_details_artist_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_details_character_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_details_pools_notifier.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_details_tags_notifier.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_video_progress_bar.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/embedded_webview_webm.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/post_video.dart';
import 'package:boorusama/core/ui/posts.dart';
import 'package:boorusama/core/ui/recommend_artist_list.dart';
import 'package:boorusama/core/ui/recommend_character_list.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'package:boorusama/core/ui/swipe_target_image.dart';
import 'package:boorusama/core/ui/widgets/circular_icon_button.dart';
import 'package:boorusama/functional.dart';

Widget providePostDetailPageDependencies(
  BuildContext context,
  List<DanbooruPost> posts,
  int initialIndex,
  Widget Function() childBuilder,
) {
  return DanbooruProvider.of(
    context,
    builder: (context) {
      return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<ThemeBloc>()),
        ],
        child: RepositoryProvider.value(
          value: context.read<TagRepository>(),
          child: childBuilder(),
        ),
      );
    },
  );
}

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
  }) {
    final page = providePostDetailPageDependencies(
      context,
      posts,
      initialIndex,
      () => DanbooruPostDetailsPage(
        intitialIndex: initialIndex,
        posts: posts,
        onExit: (page) => scrollController?.scrollToIndex(page),
      ),
    );

    return MaterialPageRoute(builder: (_) => page);
  }

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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (posts[page].isVideo)
              ValueListenableBuilder<VideoProgress>(
                valueListenable: videoProgress,
                builder: (_, progress, __) =>
                    BooruVideoProgressBar(progress: progress),
              ),
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: InformationSection(
                post: posts[page],
                showSource: true,
              ),
            ),
            DanbooruPostActionToolbar(post: posts[page]),
          ],
        );
      },
      targetSwipeDownBuilder: (context, page) => SwipeTargetImage(
        imageUrl: posts[page].url720x720,
        aspectRatio: posts[page].aspectRatio,
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets = _buildWidgets(context, expanded, page, currentPage);
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
                  imageUrl: (item) => item.url720x720,
                ),
              ],
            ),
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (page) {
        final noteState =
            ref.watch(danbooruPostDetailsNoteProvider(posts[page].id));

        return [
          Builder(builder: (_) {
            if (!posts[page].isTranslated) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return CircularIconButton(
                  icon: noteState.enableNotes
                      ? Padding(
                          padding: const EdgeInsets.all(3),
                          child: FaIcon(
                            FontAwesomeIcons.eyeSlash,
                            size: 18,
                            color: state.theme == ThemeMode.light
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(4),
                          child: FaIcon(
                            FontAwesomeIcons.eye,
                            size: 18,
                            color: state.theme == ThemeMode.light
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                        ),
                  onPressed: () => ref
                      .read(danbooruPostDetailsNoteProvider(posts[page].id)
                          .notifier)
                      .toggleNoteVisibility(),
                );
              },
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

        context.read<ArtistCommentaryCubit>().getCommentary(post.id);

        context.read<CommentsCubit>().getCommentsFromPostId(post.id);
      },
    );
  }

  List<Widget> _buildWidgets(
    BuildContext context,
    bool expanded,
    int page,
    int currentPage,
  ) {
    final post = posts[page];
    final noteState = ref.watch(danbooruPostDetailsNoteProvider(post.id));
    final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    final tags = ref.watch(danbooruPostDetailsTagsProvider(post.id));
    final expandedOnCurrentPage = expanded && page == currentPage;
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
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
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: context.read<PreviewImageCacheManager>(),
            imageOverlayBuilder: (constraints) => [
              if (expanded && noteState.enableNotes)
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
        InformationSection(post: post),
        const Divider(height: 8, thickness: 1),
        RepaintBoundary(
          child: DanbooruPostActionToolbar(post: post),
        ),
        const Divider(height: 8, thickness: 1),
        switch (post.source) {
          WebSource s => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SourceSection(
                url: s.url,
                isIcoUrl: s.hasIcoLogoSource,
              ),
            ),
          _ => const SizedBox.shrink(),
        },
        const Divider(height: 8, thickness: 1),
        TagsTile(
            tags: tags
                .where((e) => e.postId == post.id)
                .map((e) => e.name)
                .toList()),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(post: post),
        const Divider(height: 8, thickness: 1),
        BlocBuilder<ArtistCommentaryCubit, ArtistCommentaryState>(
          builder: (context, state) => AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: state.commentaryMap.lookup(post.id).fold(
                  () => const SizedBox.shrink(),
                  (commentary) => ArtistSection(
                    artistCommentary: commentary,
                    artistTags: post.artistTags,
                    source: post.source.url,
                  ),
                ),
            crossFadeState: state.commentaryMap.lookup(post.id).fold(
                  () => CrossFadeState.showFirst,
                  (_) => CrossFadeState.showSecond,
                ),
            duration: const Duration(milliseconds: 80),
          ),
        ),
        BlocBuilder<CommentsCubit, CommentsState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: RepaintBoundary(
                child: state.commentsMap.lookup(post.id).fold(
                      () => const SizedBox.shrink(),
                      (comments) => PostStatsTile(
                        post: post,
                        totalComments: comments.length,
                      ),
                    ),
              ),
            );
          },
        ),
        const Divider(height: 8, thickness: 1),
      ],
    ];
  }
}

// ignore: prefer-single-widget-per-file
class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
    required this.tags,
  });

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text('${tags.length} tags'),
        controlAffinity: ListTileControlAffinity.leading,
        onExpansionChanged: (value) =>
            value ? context.read<TagBloc>().add(TagFetched(tags: tags)) : null,
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
