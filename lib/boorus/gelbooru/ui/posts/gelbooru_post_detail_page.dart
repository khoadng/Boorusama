// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:collection/collection.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts/post_share_cubit.dart';
import 'package:boorusama/boorus/gelbooru/application/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags/tag_repository.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_video_progress_bar.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/embedded_webview_webm.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/post_video.dart';
import 'package:boorusama/core/ui/posts.dart';
import 'package:boorusama/core/ui/recommend_artist_list.dart';
import 'package:boorusama/core/ui/source_section.dart';

class GelbooruPostDetailPage extends StatefulWidget {
  const GelbooruPostDetailPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.fullscreen,
    required this.onPageChanged,
    required this.onExit,
    required this.onCachedImagePathUpdate,
  });

  final int initialIndex;
  final List<Post> posts;
  final bool fullscreen;
  final void Function(int page) onPageChanged;
  final void Function(String? imagePath) onCachedImagePathUpdate;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context, {
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
  }) {
    final settings = context.read<SettingsCubit>().state.settings;
    final booru = context.read<CurrentBooruBloc>().state.booru!;

    return MaterialPageRoute(
      builder: (_) => GelbooruProvider.of(
        context,
        booru: booru,
        builder: (gcontext) {
          final shareCubit = PostShareCubit.of(context)
            ..updateInformation(posts[initialIndex]);

          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => GelbooruPostDetailBloc(
                        postRepository: gcontext.read<PostRepository>(),
                        initialIndex: initialIndex,
                        posts: posts,
                      )..add(PostDetailRequested(index: initialIndex))),
              BlocProvider.value(value: gcontext.read<ThemeBloc>()),
              BlocProvider.value(value: shareCubit),
              BlocProvider(
                create: (_) => TagBloc(
                  tagRepository: gcontext.read<TagRepository>(),
                ),
              ),
            ],
            child: GelbooruPostDetailPage(
              posts: posts,
              initialIndex: initialIndex,
              onPageChanged: (page) {
                shareCubit.updateInformation(posts[page]);
              },
              onCachedImagePathUpdate: (imagePath) =>
                  shareCubit.setImagePath(imagePath ?? ''),
              onExit: (page) => scrollController?.scrollToIndex(page),
              fullscreen: settings.detailsDisplay == DetailsDisplay.imageFocus,
            ),
          );
        },
      ),
    );
  }

  @override
  State<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<GelbooruPostDetailPage>
    with PostDetailsPageMixin<GelbooruPostDetailPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialIndex].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => widget.onPageChanged;

  @override
  List<Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      controller: controller,
      intitialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      bottomSheet: (page) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (posts[page].isVideo)
            ValueListenableBuilder<VideoProgress>(
              valueListenable: videoProgress,
              builder: (_, progress, __) =>
                  BooruVideoProgressBar(progress: progress),
            ),
          GelbooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, index) => PostMediaItem(
        post: widget.posts[index],
      ),
      expandedBuilder: (context, page, currentPage, expanded, enableSwipe) =>
          BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final widgets = _buildWidgets(context, expanded, page, currentPage);

          return Padding(
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
                BlocBuilder<GelbooruPostDetailBloc, GelbooruPostDetailState>(
                  builder: (context, state) {
                    final artists = state.recommends
                        .where(
                            (element) => element.type == RecommendType.artist)
                        .toList();
                    return RecommendArtistList(
                      onHeaderTap: (index) =>
                          goToGelbooruArtistPage(context, artists[index].tag),
                      onTap: (recommendIndex, postIndex) =>
                          goToGelbooruPostDetailsPage(
                        context: context,
                        posts: artists[recommendIndex].posts,
                        initialIndex: postIndex,
                      ),
                      recommends: artists,
                    );
                  },
                )
              ],
            ),
          );
        },
      ),
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page) => [
        GelbooruMoreActionButton(post: widget.posts[page]),
      ],
      onExpanded: (currentPage) => context.read<TagBloc>().add(TagFetched(
            tags: widget.posts[currentPage].tags,
            onResult: (tags) {
              final t = tags
                  .firstWhereOrNull(
                      (e) => e.groupName.toLowerCase() == 'artist')
                  ?.tags;

              if (t != null) {
                context
                    .read<GelbooruPostDetailBloc>()
                    .add(GelbooruPostDetailRecommendedFetch(t));
              }
            },
          )),
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
        : InteractiveBooruImage(
            useHero: page == currentPage,
            heroTag: "${post.id}_hero",
            aspectRatio: post.aspectRatio,
            imageUrl: post.sampleLargeImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: widget.onCachedImagePathUpdate,
            previewCacheManager: context.read<PreviewImageCacheManager>(),
            width: post.width,
            height: post.height,
            onZoomUpdated: onZoomUpdated,
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
