// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/gelbooru_post_media_item.dart';
import 'package:boorusama/boorus/gelbooru/ui/tags_tile.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/source_section.dart';

class GelbooruPostDetailPage extends StatefulWidget {
  const GelbooruPostDetailPage({
    super.key,
    required this.posts,
    required this.initialIndex,
    required this.fullscreen,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<Post> posts;
  final bool fullscreen;
  final void Function(int page) onPageChanged;

  @override
  State<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<GelbooruPostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);
  late var fullscreen = widget.fullscreen;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      intitialIndex: widget.initialIndex,
      onPageChanged: widget.onPageChanged,
      targetSwipeDownBuilder: (context, index) => GelbooruPostMediaItem(
        //TODO: this is used to preload image between page
        post: widget.posts[index],
        onCached: (path) => imagePath.value = path,
        previewCacheManager: context.read<PreviewImageCacheManager>(),
        onZoomUpdated: (zoom) {},
      ),
      expandedBuilder: (context, page, currentPage, expanded) =>
          BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return _CarouselContent(
            isExpanded: expanded,
            scrollController: PageContentScrollController.of(context),

            media: GelbooruPostMediaItem(
              //TODO: this is used to preload image between page
              post: widget.posts[page],
              onCached: (path) => imagePath.value = path,
              previewCacheManager: context.read<PreviewImageCacheManager>(),
              useHero: page == currentPage,
              onZoomUpdated: (zoom) {},
            ),
            imagePath: imagePath,
            actionBarDisplayBehavior: state.settings.actionBarDisplayBehavior,
            post: widget.posts[page],
            preloadPost: widget.posts[page],
            // recommends: state.recommends,
          );
        },
      ),
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page) => [
        MoreActionButton(post: widget.posts[page]),
      ],
    );
  }
}

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({
    required this.media,
    required this.imagePath,
    required this.actionBarDisplayBehavior,
    required this.post,
    required this.preloadPost,
    required this.isExpanded,
    required this.scrollController,
  });

  final GelbooruPostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final Post post;
  final Post preloadPost;
  final ActionBarDisplayBehavior actionBarDisplayBehavior;
  final bool isExpanded;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              !isExpanded
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).viewPadding.top,
                      child: RepaintBoundary(child: media),
                    )
                  : RepaintBoundary(child: media),
              if (!isExpanded)
                SizedBox(height: MediaQuery.of(context).size.height),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // if (widget.actionBarDisplayBehavior ==
                  //     ActionBarDisplayBehavior.scrolling) ...[
                  //   RepaintBoundary(
                  //     child: ActionBar(
                  //       imagePath: widget.imagePath,
                  //       postData: widget.post,
                  //     ),
                  //   ),
                  //   const Divider(height: 8, thickness: 1),
                  // ],
                  // ArtistSection(post: widget.preloadPost),
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 8),
                  //   child: RepaintBoundary(child: PostStatsTile(post: post)),
                  // ),
                  // if (widget.preloadPost.hasParentOrChildren)
                  //   _ParentChildTile(post: widget.preloadPost),
                  TagsTile(
                    post: post,
                    onExpand: () => context
                        .read<TagBloc>()
                        .add(TagFetched(tags: post.tags)),
                    onTagTap: (tag) =>
                        goToGelbooruSearchPage(context, tag: tag.rawName),
                  ),
                  const Divider(height: 8, thickness: 1),
                  FileDetailsSection(
                    post: post,
                  ),
                  if (post.hasWebSource) SourceSection(post: post),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ignore: prefer-single-widget-per-file
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
