// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fpdart/fpdart.dart' hide State;
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/comments/comments_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_artist_character_post_repository.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/infra/preloader/preview_image_cache_manager.dart';
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
import 'package:boorusama/core/ui/widgets/circular_icon_button.dart';

Widget providePostDetailPageDependencies(
  BuildContext context,
  List<DanbooruPost> posts,
  int initialIndex,
  List<PostDetailTag> tags,
  // PostBloc? postBloc,
  Widget Function(PostShareCubit shareCubit) childBuilder,
) {
  return BlocBuilder<CurrentBooruBloc, CurrentBooruState>(
    builder: (_, state) {
      return DanbooruProvider.of(
        context,
        booru: state.booru!,
        builder: (context) {
          return BlocSelector<SettingsCubit, SettingsState, Settings>(
            selector: (state) => state.settings,
            builder: (_, settings) {
              final shareCubit = PostShareCubit.of(context)
                ..updateInformation(posts[initialIndex]);

              return MultiBlocProvider(
                providers: [
                  BlocProvider.value(
                    value: context.read<AuthenticationCubit>(),
                  ),
                  BlocProvider.value(value: context.read<ThemeBloc>()),
                  BlocProvider(
                    create: (context) => shareCubit,
                  ),
                  BlocProvider(
                    create: (context) => PostDetailBloc(
                      booruUserIdentityProvider:
                          context.read<BooruUserIdentityProvider>(),
                      noteRepository: context.read<NoteRepository>(),
                      defaultDetailsStyle: settings.detailsDisplay,
                      posts: posts,
                      initialIndex: initialIndex,
                      postRepository:
                          context.read<DanbooruArtistCharacterPostRepository>(),
                      poolRepository: context.read<PoolRepository>(),
                      currentBooruConfigRepository:
                          context.read<CurrentBooruConfigRepository>(),
                      postVoteRepository: context.read<PostVoteRepository>(),
                      tags: tags,
                      onPostChanged: (post) {
                        // if (postBloc != null && !postBloc.isClosed) {
                        //   postBloc.add(PostUpdated(post: post));
                        // }
                      },
                      tagCache: {},
                    ),
                  ),
                ],
                child: RepositoryProvider.value(
                  value: context.read<TagRepository>(),
                  child: childBuilder(shareCubit),
                ),
              );
            },
          );
        },
      );
    },
  );
}

class DanbooruPostDetailsPage extends StatefulWidget {
  const DanbooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.intitialIndex,
    required this.onPageChanged,
    required this.onCachedImagePathUpdate,
    required this.onExit,
  });

  final int intitialIndex;
  final List<DanbooruPost> posts;
  final void Function(int page) onPageChanged;
  final void Function(String? imagePath) onCachedImagePathUpdate;
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
      posts
          .map((e) => e)
          .map((p) => [
                ...p.artistTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.artist.stringify(),
                      postId: p.id,
                    )),
                ...p.characterTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.charater.stringify(),
                      postId: p.id,
                    )),
                ...p.copyrightTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.copyright.stringify(),
                      postId: p.id,
                    )),
                ...p.generalTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.general.stringify(),
                      postId: p.id,
                    )),
                ...p.metaTags.map((e) => PostDetailTag(
                      name: e,
                      category: TagCategory.meta.stringify(),
                      postId: p.id,
                    )),
              ])
          .expand((e) => e)
          .toList(),
      (shareCubit) => DanbooruPostDetailsPage(
        intitialIndex: initialIndex,
        posts: posts,
        onExit: (page) => scrollController?.scrollToIndex(page),
        onPageChanged: (page) {
          shareCubit.updateInformation(posts[page]);
        },
        onCachedImagePathUpdate: (imagePath) =>
            shareCubit.setImagePath(imagePath ?? ''),
      ),
    );

    return MaterialPageRoute(builder: (_) => page);
  }

  @override
  State<DanbooruPostDetailsPage> createState() =>
      _DanbooruPostDetailsPageState();
}

class _DanbooruPostDetailsPageState extends State<DanbooruPostDetailsPage>
    with PostDetailsPageMixin<DanbooruPostDetailsPage, DanbooruPost> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !posts[widget.intitialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => widget.onPageChanged;

  @override
  List<DanbooruPost> get posts => widget.posts;

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
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder<VideoProgress>(
              valueListenable: videoProgress,
              builder: (_, progress, __) =>
                  BooruVideoProgressBar(progress: progress),
            ),
          DanbooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, page) => PostMediaItem(
        post: posts[page],
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) {
        final widgets = _buildWidgets(context, expanded, page, currentPage);

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
              BlocBuilder<PostDetailBloc, PostDetailState>(
                builder: (context, state) {
                  final artists = state.recommends
                      .where((element) => element.type == RecommendType.artist)
                      .toList();

                  return RecommendArtistList(
                    onTap: (recommendIndex, postIndex) => goToDetailPage(
                      context: context,
                      posts: artists[recommendIndex].posts,
                      initialIndex: postIndex,
                    ),
                    onHeaderTap: (index) =>
                        goToArtistPage(context, artists[index].tag),
                    recommends: artists,
                  );
                },
              ),
              BlocBuilder<PostDetailBloc, PostDetailState>(
                builder: (context, state) {
                  final characters = state.recommends
                      .where(
                          (element) => element.type == RecommendType.character)
                      .toList();
                  return RecommendCharacterList(
                    onHeaderTap: (index) =>
                        goToCharacterPage(context, characters[index].tag),
                    onTap: (recommendIndex, postIndex) => goToDetailPage(
                      context: context,
                      posts: characters[recommendIndex].posts,
                      initialIndex: postIndex,
                      hero: false,
                    ),
                    recommends: characters,
                  );
                },
              ),
            ],
          ),
        );
      },
      pageCount: posts.length,
      topRightButtonsBuilder: (_) => [
        BlocBuilder<PostDetailBloc, PostDetailState>(
          builder: (context, dstate) {
            if (!dstate.currentPost.isTranslated) {
              return const SizedBox.shrink();
            }

            return BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return CircularIconButton(
                  icon: dstate.enableNotes
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
                  onPressed: () => context.read<PostDetailBloc>().add(
                        PostDetailNoteOptionsChanged(
                          enable: !dstate.enableNotes,
                        ),
                      ),
                );
              },
            );
          },
        ),
        const DanbooruMoreActionButton(),
      ],
      onExpanded: (currentPage) {
        final post = posts[currentPage];
        context
            .read<PostDetailBloc>()
            .add(PostDetailIndexChanged(index: currentPage));

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
    final media = post.isVideo
        ? extension(post.sampleImageUrl) == '.webm'
            ? EmbeddedWebViewWebm(
                url: post.sampleImageUrl,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
            : BooruVideo(
                url: post.sampleImageUrl,
                aspectRatio: post.aspectRatio,
                onCurrentPositionChanged: onCurrentPositionChanged,
                onVisibilityChanged: onVisibilityChanged,
              )
        : BlocBuilder<PostDetailBloc, PostDetailState>(
            builder: (context, state) {
              return InteractiveBooruImage(
                useHero: page == currentPage,
                heroTag: "${post.id}_hero",
                aspectRatio: post.aspectRatio,
                imageUrl: post.sampleLargeImageUrl,
                placeholderImageUrl: post.thumbnailImageUrl,
                onTap: onImageTap,
                onCached: widget.onCachedImagePathUpdate,
                previewCacheManager: context.read<PreviewImageCacheManager>(),
                imageOverlayBuilder: (constraints) => [
                  if (expanded)
                    ...state.notes
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
            },
          );

    return [
      if (!expanded)
        SizedBox(
          height: MediaQuery.of(context).size.height -
              MediaQuery.of(context).viewPadding.top,
          child: RepaintBoundary(child: media),
        )
      else if (post.isVideo)
        BooruImage(imageUrl: post.thumbnailImageUrl)
      else
        RepaintBoundary(child: media),
      if (!expanded) SizedBox(height: MediaQuery.of(context).size.height),
      if (expanded) ...[
        BlocBuilder<PostDetailBloc, PostDetailState>(
          buildWhen: (previous, current) => previous.pools != current.pools,
          builder: (context, state) {
            return PoolTiles(pools: state.pools);
          },
        ),
        InformationSection(post: post),
        const Divider(height: 8, thickness: 1),
        RepaintBoundary(
          child: DanbooruPostActionToolbar(post: post),
        ),
        const Divider(height: 8, thickness: 1),
        BlocBuilder<ArtistCommentaryCubit, ArtistCommentaryState>(
            builder: (context, state) =>
                state.commentaryMap.lookup(post.id).fold(
                      () => const SizedBox.shrink(),
                      (commentary) => ArtistSection(
                        artistCommentary: commentary,
                        artistTags: post.artistTags,
                        source: post.source,
                      ),
                    )),
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
        if (post.hasParentOrChildren)
          ParentChildTile(
            data: getParentChildData(post),
            onTap: (data) => goToParentChildPage(
              context,
              data.parentId,
              data.tagQueryForDataFetching,
            ),
          ),
        if (!post.hasParentOrChildren) const Divider(height: 8, thickness: 1),
        TagsTile(post: post),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(
          post: post,
        ),
        if (post.hasWebSource)
          SourceSection(
            post: post,
          ),
      ],
    ];
  }
}

// ignore: prefer-single-widget-per-file
class TagsTile extends StatelessWidget {
  const TagsTile({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

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
