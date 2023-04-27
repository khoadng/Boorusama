// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru_provider.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/boorus/moebooru/ui/moebooru_post_action_toolbar.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus/booru.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_video_progress_bar.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/embedded_webview_webm.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/post_video.dart';
import 'package:boorusama/core/ui/posts.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'package:boorusama/core/ui/tags/basic_tag_list.dart';

class MoebooruPostDetailsPage extends StatefulWidget {
  const MoebooruPostDetailsPage({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.fullscreen,
    required this.onPageChanged,
    required this.onExit,
    required this.onCachedImagePathUpdate,
  });

  final List<Post> posts;
  final int initialPage;
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
      builder: (_) {
        final shareCubit = PostShareCubit.of(context)
          ..updateInformation(posts[initialIndex]);

        return MoebooruProvider.of(
          context,
          booru: booru,
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: shareCubit),
            ],
            child: MoebooruPostDetailsPage(
              posts: posts,
              onExit: (page) => scrollController?.scrollToIndex(page),
              onPageChanged: (page) {
                shareCubit.updateInformation(posts[page]);
              },
              onCachedImagePathUpdate: (imagePath) =>
                  shareCubit.setImagePath(imagePath ?? ''),
              initialPage: initialIndex,
              fullscreen: settings.detailsDisplay == DetailsDisplay.imageFocus,
            ),
          ),
        );
      },
    );
  }

  @override
  State<MoebooruPostDetailsPage> createState() =>
      _MoebooruPostDetailsPageState();
}

class _MoebooruPostDetailsPageState extends State<MoebooruPostDetailsPage>
    with PostDetailsPageMixin<MoebooruPostDetailsPage, Post> {
  late final _controller = DetailsPageController(
      swipeDownToDismiss: !widget.posts[widget.initialPage].isVideo);

  @override
  DetailsPageController get controller => _controller;

  @override
  Function(int page) get onPageChanged => widget.onPageChanged;

  @override
  List<Post> get posts => widget.posts;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      intitialIndex: widget.initialPage,
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
          MoebooruPostActionToolbar(post: posts[page]),
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
              ],
            ),
          );
        },
      ),
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (currentPage) => [
        MoreActionButton(
          post: widget.posts[currentPage],
        ),
      ],
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
        Padding(
          padding: const EdgeInsets.all(8),
          child: BasicTagList(
            tags: post.tags,
            onTap: (tag) => goToMoebooruSearchPage(context, tag: tag),
          ),
        ),
        const Divider(
          thickness: 1.5,
          height: 4,
        ),
        FileDetailsSection(
          post: post,
        ),
        if (post.hasWebSource) SourceSection(post: post),
      ],
    ];
  }
}

class MoreActionButton extends StatelessWidget {
  const MoreActionButton({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context) {
    final endpoint = context.select(
      (CurrentBooruBloc bloc) => bloc.state.booru?.url ?? safebooru().url,
    );

    final booru = context.select((CurrentBooruBloc bloc) => bloc.state.booru);

    return DownloadProviderWidget(
      builder: (context, download) => SizedBox(
        width: 40,
        child: Material(
          color: Colors.black.withOpacity(0.5),
          shape: const CircleBorder(),
          child: PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            onSelected: (value) {
              switch (value) {
                case 'download':
                  download(post);
                  break;
                case 'add_to_bookmark':
                  context.read<BookmarkCubit>().addBookmark(
                        post.sampleImageUrl,
                        booru!,
                        post,
                      );
                  break;
                case 'view_in_browser':
                  launchExternalUrl(
                    post.getUriLink(endpoint),
                  );
                  break;
                case 'view_original':
                  goToOriginalImagePage(context, post);
                  break;
                // ignore: no_default_cases
                default:
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'download',
                child: const Text('download.download').tr(),
              ),
              const PopupMenuItem(
                value: 'add_to_bookmark',
                child: Text('Add to Bookmark'),
              ),
              PopupMenuItem(
                value: 'view_in_browser',
                child: const Text('post.detail.view_in_browser').tr(),
              ),
              if (!post.isVideo)
                PopupMenuItem(
                  value: 'view_original',
                  child: const Text('post.image_fullview.view_original').tr(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
