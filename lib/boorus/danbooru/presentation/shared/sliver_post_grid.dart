// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/application/theme/theme.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/application/download/i_download_service.dart';
import 'package:boorusama/core/presentation/grid_size.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';
import 'package:boorusama/core/utils.dart';

enum ImageQuality {
  low,
  high,
  original,
}

class SliverPostGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  SliverPostGridDelegate({
    required int crossAxisCount,
    required double mainAxisSpacing,
    required double crossAxisSpacing,
    required double childAspectRatio,
    double? mainAxisExtent,
  }) : super(
          childAspectRatio: childAspectRatio,
          crossAxisCount: crossAxisCount,
          mainAxisExtent: mainAxisExtent,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        );
  factory SliverPostGridDelegate.normal() => SliverPostGridDelegate(
        childAspectRatio: 0.65,
        crossAxisCount: 2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      );

  factory SliverPostGridDelegate.small() => SliverPostGridDelegate(
        childAspectRatio: 1,
        crossAxisCount: 3,
        mainAxisSpacing: 2.5,
        crossAxisSpacing: 2.5,
      );
  factory SliverPostGridDelegate.large() => SliverPostGridDelegate(
        childAspectRatio: 0.65,
        crossAxisCount: 1,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      );
}

class SliverPostGrid extends HookWidget {
  const SliverPostGrid({
    Key? key,
    required this.posts,
    required this.scrollController,
    this.onItemChanged,
    this.onTap,
    this.quality,
    this.gridSize = GridSize.normal,
    this.borderRadius,
    this.postAnnotationBuilder,
  }) : super(key: key);

  final List<Post> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int>? onItemChanged;
  final void Function(Post post, int index)? onTap;
  final ImageQuality? quality;
  final GridSize gridSize;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext context, Post post, int index)?
      postAnnotationBuilder;

  @override
  Widget build(BuildContext context) {
    // Workaround to prevent memory leak, clear images every 10 seconds
    final timer = useState(Timer.periodic(const Duration(seconds: 10), (_) {
      PaintingBinding.instance.imageCache.clearLiveImages();
    }));

    useEffect(() {
      return () => timer.value.cancel();
    }, []);

    // Clear live image cache everytime this widget built
    useEffect(() {
      PaintingBinding.instance.imageCache.clearLiveImages();

      return () {};
    });

    return SliverGrid(
      gridDelegate: gridSizeToGridDelegate(gridSize),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          final post = posts[index];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: SliverPostGridItem(
                  post: post,
                  index: index,
                  borderRadius: borderRadius,
                  gridSize: gridSize,
                  scrollController: scrollController,
                  onTap: onTap,
                ),
              ),
              postAnnotationBuilder?.call(context, post, index) ??
                  const SizedBox.shrink(),
            ],
          );
        },
        childCount: posts.length,
      ),
    );
  }
}

class SliverPostGridItem extends StatelessWidget {
  const SliverPostGridItem(
      {Key? key,
      required this.post,
      required this.index,
      required this.borderRadius,
      required this.gridSize,
      this.onTap,
      required this.scrollController})
      : super(key: key);

  final Post post;
  final int index;
  final AutoScrollController scrollController;
  final void Function(Post post, int index)? onTap;
  final GridSize gridSize;
  final BorderRadiusGeometry? borderRadius;
  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (post.isAnimated) {
      items.add(
        const Icon(
          Icons.play_circle_outline,
          color: Colors.white70,
        ),
      );
    }

    if (post.isTranslated) {
      items.add(
        const Icon(
          Icons.g_translate_outlined,
          color: Colors.white70,
        ),
      );
    }

    if (post.hasComment) {
      items.add(
        const Icon(
          Icons.comment,
          color: Colors.white70,
        ),
      );
    }

    return AutoScrollTag(
      index: index,
      controller: scrollController,
      key: ValueKey(index),
      child: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () => onTap?.call(post, index),
            onLongPress: () {
              showBarModalBottomSheet(
                duration: const Duration(milliseconds: 200),
                expand: true,
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => PostPreviewSheet(
                  post: post,
                  scrollController: ModalScrollController.of(context),
                  onImageTap: () => onTap?.call(post, index),
                ),
              );
            },
            child: PostImage(
              imageUrl: _getImageUrl(post, _gridSizeToImageQuality(gridSize)),
              placeholderUrl: post.previewImageUrl,
              borderRadius: borderRadius,
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ShadowGradientOverlay(
              alignment: Alignment.topCenter,
              colors: <Color>[
                const Color(0x2F000000),
                Colors.black12.withOpacity(0)
              ],
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: IgnorePointer(
              child: Column(
                children: items,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

SliverGridDelegate gridSizeToGridDelegate(GridSize size) {
  switch (size) {
    case GridSize.large:
      return SliverPostGridDelegate.large();
    case GridSize.small:
      return SliverPostGridDelegate.small();
    default:
      return SliverPostGridDelegate.normal();
  }
}

ImageQuality _gridSizeToImageQuality(GridSize size) {
  if (size == GridSize.small) return ImageQuality.low;

  return ImageQuality.high;
}

String _getImageUrl(Post post, ImageQuality quality) {
  if (post.isAnimated) return post.previewImageUrl;
  if (quality == ImageQuality.low) return post.previewImageUrl;
  return post.normalImageUrl;
}

class PostPreviewSheet extends HookWidget {
  const PostPreviewSheet({
    Key? key,
    required this.post,
    required this.scrollController,
    this.onImageTap,
  }) : super(key: key);

  final Post post;
  final ScrollController? scrollController;
  final VoidCallback? onImageTap;

  @override
  Widget build(BuildContext context) {
    final artistTags = post.artistTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.artist])
        .toList();
    final copyrightTags = post.copyrightTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.copyright])
        .toList();
    final characterTags = post.characterTags
        .where((e) => e.isNotEmpty)
        .map((e) => [e, TagCategory.charater])
        .toList();

    final tags = [
      ...artistTags,
      ...copyrightTags,
      ...characterTags,
    ];

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onImageTap?.call();
                  },
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: post.isAnimated
                        ? post.previewImageUrl
                        : post.normalImageUrl,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Tags(
              runSpacing: 0,
              itemCount: tags.length,
              itemBuilder: (index) {
                return BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    return Chip(
                        padding: const EdgeInsets.all(4),
                        labelPadding: const EdgeInsets.all(1),
                        visualDensity: VisualDensity.compact,
                        backgroundColor: getTagColor(
                          tags[index][1] as TagCategory,
                          state.theme,
                        ),
                        label: ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.85),
                          child: Text(
                            (tags[index][0] as String)
                                .removeUnderscoreWithSpace(),
                            overflow: TextOverflow.fade,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ));
                  },
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  BlocSelector<SettingsCubit, SettingsState, String?>(
                    selector: (state) => state.settings.downloadPath,
                    builder: (context, path) {
                      return ListTile(
                        leading: const Icon(Icons.file_download),
                        title: const Text('Download'),
                        onTap: () {
                          RepositoryProvider.of<IDownloadService>(context)
                              .download(
                            post,
                            path: path,
                          );
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                  if (post.isTranslated)
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.language),
                      title: const Text('View translated notes'),
                      onTap: () {
                        Navigator.of(context).pop();
                        AppRouter.router.navigateTo(context, '/posts/image',
                            routeSettings: RouteSettings(arguments: [post]));
                      },
                    )
                  else
                    const SizedBox.shrink(),
                  // isLoggedIn
                  //     ? ListTile(
                  //         leading: const FaIcon(FontAwesomeIcons.commentAlt),
                  //         title: const Text("Comment"),
                  //         onTap: () {
                  //           Navigator.of(context).pop();
                  //           Navigator.of(context).push(SlideInRoute(
                  //               pageBuilder: (_, __, ___) =>
                  //                   CommentCreatePage(postId: post.id)));
                  //         },
                  //       )
                  //     : SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
