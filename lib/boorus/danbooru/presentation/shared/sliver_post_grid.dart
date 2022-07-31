// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/presentation/download_provider_widget.dart';

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
        crossAxisCount: displaySizeToGridCountWeight(size) * 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );

  factory SliverPostGridDelegate.small(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 1,
        crossAxisCount: displaySizeToGridCountWeight(size) * 3,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
  factory SliverPostGridDelegate.large(double spacing, ScreenSize size) =>
      SliverPostGridDelegate(
        childAspectRatio: 0.65,
        crossAxisCount: displaySizeToGridCountWeight(size),
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
      );
}

int displaySizeToGridCountWeight(ScreenSize size) {
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
      child: _buildImage(context),
    );
  }

  Widget _buildOverlayIcon() {
    return IgnorePointer(
      child: Wrap(
        children: [
          if (post.isAnimated)
            const _OverlayIcon(icon: Icons.play_circle_outline, size: 20),
          if (post.isTranslated)
            const _OverlayIcon(icon: Icons.g_translate_outlined, size: 20),
          if (post.hasComment)
            const _OverlayIcon(icon: Icons.comment, size: 20),
          if (post.hasParentOrChildren)
            const _OverlayIcon(icon: FontAwesomeIcons.images, size: 16),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return CupertinoContextMenu(
      previewBuilder: (context, animation, child) => PostImage(
        imageUrl: getImageUrlForDisplay(
            post,
            getImageQuality(
              size: gridSize,
              presetImageQuality: imageQuality,
            )),
        placeholderUrl: post.previewImageUrl,
        fit: BoxFit.contain,
      ),
      actions: [
        DownloadProviderWidget(
          builder: (context, download) => CupertinoContextMenuAction(
            trailingIcon: Icons.download,
            onPressed: () {
              Navigator.of(context).pop();
              download(post);
            },
            child: const Text('download.download').tr(),
          ),
        ),
        if (post.isTranslated)
          CupertinoContextMenuAction(
            trailingIcon: Icons.translate,
            onPressed: () {
              Navigator.of(context).pop();
              AppRouter.router.navigateTo(
                context,
                '/posts/image',
                routeSettings: RouteSettings(arguments: [post]),
                transition: TransitionType.material,
              );
            },
            child: const Text('post.quick_preview.view_notes').tr(),
          ),
      ],
      child: GestureDetector(
        onTap: () => onTap?.call(post, index),
        child: Stack(
          children: [
            PostImage(
              imageUrl: getImageUrlForDisplay(
                  post,
                  getImageQuality(
                    size: gridSize,
                    presetImageQuality: imageQuality,
                  )),
              placeholderUrl: post.previewImageUrl,
              borderRadius: borderRadius,
            ),
            _buildOverlayIcon()
          ],
        ),
      ),
    );
  }
}

class _OverlayIcon extends StatelessWidget {
  const _OverlayIcon({
    Key? key,
    required this.icon,
    this.size,
  }) : super(key: key);

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      width: 25,
      height: 25,
      child: Icon(
        icon,
        color: Colors.white70,
        size: size,
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
