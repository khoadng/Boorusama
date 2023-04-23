// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:exprollable_page_view/exprollable_page_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_detail_bloc.dart';
import 'package:boorusama/boorus/gelbooru/application/gelbooru_post_detail_state.dart';
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/boorus/gelbooru/ui/tags_tile.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/details_page.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
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
  });

  final int initialIndex;
  final List<Post> posts;
  final bool fullscreen;
  final void Function(int page) onPageChanged;
  final void Function(int page) onExit;

  @override
  State<GelbooruPostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<GelbooruPostDetailPage> {
  final imagePath = ValueNotifier<String?>(null);
  var enableSwipe = true;
  var hideOverlay = false;

  @override
  Widget build(BuildContext context) {
    return DetailsPage(
      intitialIndex: widget.initialIndex,
      enablePageSwipe: enableSwipe,
      hideOverlay: hideOverlay,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      targetSwipeDownBuilder: (context, index) => PostMediaItem(
        post: widget.posts[index],
      ),
      expandedBuilder: (context, page, currentPage, expanded) =>
          BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return _CarouselContent(
            physics: enableSwipe ? null : const NeverScrollableScrollPhysics(),
            isExpanded: expanded,
            scrollController: PageContentScrollController.of(context),
            media: PostMediaItem(
              post: widget.posts[page],
              onCached: (path) => imagePath.value = path,
              previewCacheManager: context.read<PreviewImageCacheManager>(),
              useHero: page == currentPage,
              onTap: () {
                setState(() {
                  hideOverlay = !hideOverlay;
                });
              },
              onZoomUpdated: (zoom) {
                final swipe = !zoom;
                if (swipe != enableSwipe) {
                  setState(() {
                    enableSwipe = swipe;
                  });
                }
              },
            ),
            post: widget.posts[page],
            preloadPost: widget.posts[page],
          );
        },
      ),
      pageCount: widget.posts.length,
      topRightButtonsBuilder: (page) => [
        MoreActionButton(post: widget.posts[page]),
      ],
      onExpanded: (currentPage) => context.read<TagBloc>().add(TagFetched(
            tags: widget.posts[currentPage].tags,
            onResult: (tags) {
              final t = tags
                  .firstWhere((e) => e.groupName.toLowerCase() == 'artist')
                  .tags;
              context
                  .read<GelbooruPostDetailBloc>()
                  .add(GelbooruPostDetailRecommendedFetch(t));
            },
          )),
    );
  }
}

class _CarouselContent extends StatelessWidget {
  const _CarouselContent({
    required this.media,
    required this.post,
    required this.preloadPost,
    required this.isExpanded,
    required this.scrollController,
    this.physics,
  });

  final PostMediaItem media;
  final Post post;
  final Post preloadPost;
  final bool isExpanded;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final widgets = _buildWidgets(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        physics: physics,
        controller: scrollController,
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => widgets[index],
              childCount: widgets.length,
            ),
          ),
          BlocBuilder<GelbooruPostDetailBloc, GelbooruPostDetailState>(
            builder: (context, state) => RecommendArtistList(
              onHeaderTap: (index) =>
                  goToGelbooruArtistPage(context, state.recommends[index].tag),
              onTap: (recommendIndex, postIndex) => goToGelbooruPostDetailsPage(
                context: context,
                posts: state.recommends[recommendIndex].posts,
                initialIndex: postIndex,
              ),
              recommends: state.recommends
                  .where((element) => element.type == RecommendType.artist)
                  .toList(),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildWidgets(BuildContext context) => [
        if (!isExpanded)
          SizedBox(
            height: MediaQuery.of(context).size.height -
                MediaQuery.of(context).viewPadding.top,
            child: RepaintBoundary(child: media),
          )
        else
          RepaintBoundary(child: media),
        if (!isExpanded) SizedBox(height: MediaQuery.of(context).size.height),
        if (isExpanded) ...[
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
