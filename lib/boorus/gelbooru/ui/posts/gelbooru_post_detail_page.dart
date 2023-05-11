// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:collection/collection.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/gelbooru/application/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
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
import 'package:boorusama/core/ui/source_section.dart';

class GelbooruPostDetailPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.fullscreen,
    // required this.onPageChanged,
    // required this.onCachedImagePathUpdate,
    required this.onExit,
  });

  final int initialIndex;
  final List<Post> posts;
  final bool fullscreen;
  // final void Function(int page) onPageChanged;
  // final void Function(String? imagePath) onCachedImagePathUpdate;
  final void Function(int page) onExit;

  static MaterialPageRoute routeOf(
    BuildContext context, {
    required Settings settings,
    required List<Post> posts,
    required int initialIndex,
    AutoScrollController? scrollController,
  }) {
    return MaterialPageRoute(
      builder: (_) => GelbooruProvider.of(
        context,
        builder: (gcontext) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                  create: (_) => GelbooruPostDetailBloc(
                        postRepository: gcontext.read<PostRepository>(),
                        initialIndex: initialIndex,
                        posts: posts,
                      )..add(PostDetailRequested(index: initialIndex))),
              BlocProvider.value(value: gcontext.read<ThemeBloc>()),
            ],
            child: GelbooruPostDetailPage(
              posts: posts,
              initialIndex: initialIndex,
              // onPageChanged: (page) {
              //   shareCubit.updateInformation(posts[page]);
              // },
              // onCachedImagePathUpdate: (imagePath) =>
              //     shareCubit.setImagePath(imagePath ?? ''),
              onExit: (page) => scrollController?.scrollToIndex(page),
              fullscreen: settings.detailsDisplay == DetailsDisplay.imageFocus,
            ),
          );
        },
      ),
    );
  }

  @override
  ConsumerState<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends ConsumerState<GelbooruPostDetailPage>
    with PostDetailsPageMixin<GelbooruPostDetailPage, Post> {
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
              builder: (_, progress, __) =>
                  BooruVideoProgressBar(progress: progress),
            ),
          GelbooruPostActionToolbar(post: posts[page]),
        ],
      ),
      targetSwipeDownBuilder: (context, index) => PostMediaItem(
        post: widget.posts[index],
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
              BlocBuilder<GelbooruPostDetailBloc, GelbooruPostDetailState>(
                builder: (context, state) {
                  final artists = state.recommends
                      .where((element) => element.type == RecommendType.artist)
                      .toList();
                  return RecommendArtistList(
                    onHeaderTap: (index) =>
                        goToGelbooruArtistPage(context, artists[index].tag),
                    onTap: (recommendIndex, postIndex) =>
                        goToGelbooruPostDetailsPage(
                      context: context,
                      posts: artists[recommendIndex].posts,
                      initialIndex: postIndex,
                      settings: ref.read(settingsProvider),
                    ),
                    recommends: artists,
                    imageUrl: (item) => item.thumbnailImageUrl,
                  );
                },
              )
            ],
          ),
        );
      },
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
    final expandedOnCurrentPage = expanded && page == currentPage;
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
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            onTap: onImageTap,
            onCached: (path) => ref
                .read(postShareProvider(post).notifier)
                .setImagePath(path ?? ''),
            previewCacheManager: context.read<PreviewImageCacheManager>(),
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
        BooruImage(imageUrl: post.thumbnailImageUrl)
      else
        RepaintBoundary(child: media),
      if (!expandedOnCurrentPage)
        SizedBox(height: MediaQuery.of(context).size.height),
      if (expandedOnCurrentPage) ...[
        TagsTile(
          post: post,
          onTagTap: (tag) => goToGelbooruSearchPage(context, tag: tag.rawName),
        ),
        const Divider(height: 8, thickness: 1),
        FileDetailsSection(
          post: post,
        ),
        post.source.whenWeb(
          (source) => SourceSection(url: source.url),
          () => const SizedBox.shrink(),
        ),
      ],
    ];
  }
}
