// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter/services.dart';

// Package imports:
import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/ui/features/post_detail/post_detail_page.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/core/application/bookmarks.dart';
import 'package:boorusama/core/application/current_booru_bloc.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/domain/boorus/booru.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/ui/circular_icon_button.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/file_details_section.dart';
import 'package:boorusama/core/ui/post_media_item.dart';
import 'package:boorusama/core/ui/source_section.dart';
import 'package:boorusama/core/ui/tags/basic_tag_list.dart';

class MoebooruPostDetails extends StatefulWidget {
  const MoebooruPostDetails({
    super.key,
    required this.posts,
    required this.initialPage,
    required this.fullscreen,
  });

  final List<Post> posts;
  final int initialPage;
  final bool fullscreen;

  @override
  State<MoebooruPostDetails> createState() => _MoebooruPostDetailsState();
}

class _MoebooruPostDetailsState extends State<MoebooruPostDetails> {
  final imagePath = ValueNotifier<String?>(null);
  late final currentIndex = ValueNotifier(widget.initialPage);
  late var fullscreen = widget.fullscreen;

  @override
  Widget build(BuildContext context) {
    final theme = context.select((ThemeBloc bloc) => bloc.state.theme);

    return Scaffold(
      body: Stack(
        children: [
          MoebooruPostSlider(
            fullscreen: fullscreen,
            posts: widget.posts,
            imagePath: imagePath,
            initialPage: widget.initialPage,
            onPageChange: (index) => currentIndex.value = index,
          ),
          Align(
            alignment: const Alignment(
              -0.95,
              -0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CircularIconButton(
                icon: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: theme == ThemeMode.light
                      ? Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).colorScheme.onPrimary,
                        )
                      : const Icon(Icons.arrow_back_ios),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
          Align(
            alignment: const Alignment(
              0.9,
              -0.9,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: ButtonBar(
                children: [
                  CircularIconButton(
                    icon: fullscreen
                        ? Icon(
                            Icons.fullscreen_exit,
                            color: theme == ThemeMode.light
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          )
                        : Icon(
                            Icons.fullscreen,
                            color: theme == ThemeMode.light
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                    onPressed: () => setState(() {
                      fullscreen = !fullscreen;
                    }),
                  ),
                  ValueListenableBuilder<int>(
                    valueListenable: currentIndex,
                    builder: (context, value, child) => MoreActionButton(
                      post: widget.posts[value],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

class MoebooruPostSlider extends StatefulWidget {
  const MoebooruPostSlider({
    super.key,
    required this.posts,
    required this.imagePath,
    required this.initialPage,
    required this.onPageChange,
    required this.fullscreen,
  });

  final List<Post> posts;
  final ValueNotifier<String?> imagePath;
  final int initialPage;
  final void Function(int index) onPageChange;
  final bool fullscreen;

  @override
  State<MoebooruPostSlider> createState() => _PostSliderState();
}

class _PostSliderState extends State<MoebooruPostSlider> {
  var enableSwipe = true;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: widget.posts.length,
      itemBuilder: (context, index, realIndex) {
        final media = PostMediaItem(
          //TODO: this is used to preload image between page
          post: widget.posts[index],
          onCached: (path) => widget.imagePath.value = path,
          previewCacheManager: context.read<PreviewImageCacheManager>(),
          onZoomUpdated: (zoom) {
            final swipe = !zoom;
            if (swipe != enableSwipe) {
              setState(() {
                enableSwipe = swipe;
              });
            }
          },
        );

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Stack(
              children: [
                if (!widget.fullscreen)
                  _CarouselContent(
                    media: media,
                    imagePath: widget.imagePath,
                    post: widget.posts[index],
                    preloadPost: widget.posts[index],
                  )
                else
                  Center(
                    child: media,
                  ),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        scrollPhysics: enableSwipe
            ? const DetailPageViewScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        height: MediaQuery.of(context).size.height,
        viewportFraction: 1,
        enableInfiniteScroll: false,
        initialPage: widget.initialPage,
        onPageChanged: (index, reason) => widget.onPageChange(index),
      ),
    );
  }
}

class _CarouselContent extends StatefulWidget {
  const _CarouselContent({
    required this.media,
    required this.imagePath,
    required this.post,
    required this.preloadPost,
  });

  final PostMediaItem media;
  final ValueNotifier<String?> imagePath;
  final Post post;
  final Post preloadPost;

  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  Post get post => widget.post;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              RepaintBoundary(child: widget.media),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
