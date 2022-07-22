// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';
import 'package:boorusama/core/presentation/widgets/shadow_gradient_overlay.dart';

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
  factory SliverPostGridDelegate.normal(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: size != ScreenSize.small ? 0.9 : 0.65,
        crossAxisCount: _displaySizeToGridCountWeight(size) * 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );

  factory SliverPostGridDelegate.small(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 1,
        crossAxisCount: _displaySizeToGridCountWeight(size) * 3,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
  factory SliverPostGridDelegate.large(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 0.65,
        crossAxisCount: _displaySizeToGridCountWeight(size),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
}

int _displaySizeToGridCountWeight(ScreenSize size) {
  if (size == ScreenSize.small) return 1;
  if (size == ScreenSize.medium) return 2;
  return 3;
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

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.imageBorderRadius !=
              current.settings.imageBorderRadius ||
          previous.settings.imageGridSpacing !=
              current.settings.imageGridSpacing ||
          previous.settings.imageQuality != current.settings.imageQuality,
      builder: (context, state) {
        return SliverGrid(
          gridDelegate: gridSizeToGridDelegate(
            size: gridSize,
            spacing: state.settings.imageGridSpacing,
            screenWidth: MediaQuery.of(context).size.width,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final post = posts[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: SliverPostGridItem(
                      post: post,
                      index: index,
                      borderRadius: BorderRadius.circular(
                          state.settings.imageBorderRadius),
                      gridSize: gridSize,
                      scrollController: scrollController,
                      imageQuality: state.settings.imageQuality,
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
      },
    );
  }
}

class SliverPostGridItem extends StatelessWidget {
  const SliverPostGridItem({
    Key? key,
    required this.post,
    required this.index,
    required this.borderRadius,
    required this.gridSize,
    this.onTap,
    required this.imageQuality,
    required this.scrollController,
  }) : super(key: key);

  final Post post;
  final int index;
  final AutoScrollController scrollController;
  final void Function(Post post, int index)? onTap;
  final GridSize gridSize;
  final BorderRadius? borderRadius;
  final ImageQuality imageQuality;

  @override
  Widget build(BuildContext context) {
    return AutoScrollTag(
      index: index,
      controller: scrollController,
      key: ValueKey(index),
      child: Stack(
        children: [
          _buildImage(context),
          _buildShadow(),
          _buildOverlayIcon(),
        ],
      ),
    );
  }

  Widget _buildOverlayIcon() {
    return Positioned(
      top: 6,
      left: 6,
      child: IgnorePointer(
        child: Column(
          children: [
            if (post.isAnimated)
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
              ),
            if (post.isTranslated)
              const Icon(
                Icons.g_translate_outlined,
                color: Colors.white70,
              ),
            if (post.hasComment)
              const Icon(
                Icons.comment,
                color: Colors.white70,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShadow() {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: ShadowGradientOverlay(
        alignment: Alignment.topCenter,
        colors: <Color>[const Color(0x2F000000), Colors.black12.withOpacity(0)],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return GestureDetector(
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
        imageUrl: getImageUrlForDisplay(
            post,
            getImageQuality(
              size: gridSize,
              presetImageQuality: imageQuality,
            )),
        placeholderUrl: post.previewImageUrl,
        borderRadius: borderRadius,
      ),
    );
  }
}

SliverGridDelegate gridSizeToGridDelegate({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  switch (size) {
    case GridSize.large:
      return SliverPostGridDelegate.large(spacing, displaySize);
    case GridSize.small:
      return SliverPostGridDelegate.small(spacing, displaySize);
    default:
      return SliverPostGridDelegate.normal(spacing, displaySize);
  }
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
                  DownloadProviderWidget(
                    builder: (context, download) => ListTile(
                      leading: const Icon(Icons.file_download),
                      title: const Text('download.download').tr(),
                      onTap: () {
                        download(post);
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  if (post.isTranslated)
                    ListTile(
                      leading: const FaIcon(FontAwesomeIcons.language),
                      title: const Text('post.quick_preview.view_notes').tr(),
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
