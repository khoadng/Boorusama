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
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/shared/shared.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';

class SliverPostGridDelegate extends SliverGridDelegateWithFixedCrossAxisCount {
  SliverPostGridDelegate({
    required super.crossAxisCount,
    required super.mainAxisSpacing,
    required super.crossAxisSpacing,
    required super.childAspectRatio,
    super.mainAxisExtent,
  });
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
    super.key,
    required this.posts,
    required this.scrollController,
    required this.onFavoriteUpdated,
    this.onItemChanged,
    this.onTap,
    this.quality,
    this.gridSize = GridSize.normal,
    this.borderRadius,
    this.postAnnotationBuilder,
  });

  final List<PostData> posts;
  final AutoScrollController scrollController;
  final ValueChanged<int>? onItemChanged;
  final void Function(Post post, int index)? onTap;
  final ImageQuality? quality;
  final GridSize gridSize;
  final BorderRadiusGeometry? borderRadius;
  final Widget Function(BuildContext context, Post post, int index)?
      postAnnotationBuilder;
  final void Function(int postId, bool value) onFavoriteUpdated;

  @override
  Widget build(BuildContext context) {
    // Workaround to prevent memory leak, clear images every 10 seconds
    final timer = useState(Timer.periodic(const Duration(seconds: 10), (_) {
      PaintingBinding.instance.imageCache.clearLiveImages();
    }));

    useEffect(
      () {
        return () => timer.value.cancel();
      },
      [],
    );

    // Clear live image cache everytime this widget built
    useEffect(() {
      PaintingBinding.instance.imageCache.clearLiveImages();

      // ignore: no-empty-block
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
                    child: ImageGridItem(
                      autoScrollOptions: AutoScrollOptions(
                        controller: scrollController,
                        index: index,
                      ),
                      borderRadius: BorderRadius.circular(
                        state.settings.imageBorderRadius,
                      ),
                      gridSize: gridSize,
                      imageQuality: state.settings.imageQuality,
                      onTap: () => onTap?.call(post.post, index),
                      isAnimated: post.post.isAnimated,
                      isTranslated: post.post.isTranslated,
                      hasComments: post.post.hasComment,
                      hasParentOrChildren: post.post.hasBothParentAndChildren,
                      previewUrl: getImageUrlForDisplay(
                        post.post,
                        getImageQuality(
                          size: gridSize,
                          presetImageQuality: state.settings.imageQuality,
                        ),
                      ),
                      previewPlaceholderUrl: post.post.previewImageUrl,
                      contextMenuAction: [
                        DownloadProviderWidget(
                          builder: (context, download) =>
                              CupertinoContextMenuAction(
                            trailingIcon: Icons.download,
                            onPressed: () {
                              Navigator.of(context).pop();
                              download(post.post);
                            },
                            child: const Text('download.download').tr(),
                          ),
                        ),
                        FutureBuilder<Account>(
                          future: context.read<AccountRepository>().get(),
                          builder: (context, snapshot) {
                            return snapshot.hasData &&
                                    snapshot.data! != Account.empty
                                ? CupertinoContextMenuAction(
                                    trailingIcon: post.isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_outline,
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      final action = post.isFavorited
                                          ? context
                                              .read<FavoritePostRepository>()
                                              .removeFromFavorites(post.post.id)
                                          : context
                                              .read<FavoritePostRepository>()
                                              .addToFavorites(post.post.id);
                                      final success = await action;
                                      final successMsg = post.isFavorited
                                          ? 'favorites.unfavorited'
                                          : 'favorites.favorited';
                                      final failMsg = post.isFavorited
                                          ? 'favorites.fail_to_unfavorite'
                                          : 'favorites.fail_to_favorite';
                                      if (success) {
                                        onFavoriteUpdated.call(
                                          post.post.id,
                                          !post.isFavorited,
                                        );
                                        showSimpleSnackBar(
                                          context: context,
                                          content: Text(successMsg).tr(),
                                          duration: const Duration(seconds: 1),
                                        );
                                      } else {
                                        showSimpleSnackBar(
                                          context: context,
                                          content: Text(failMsg).tr(),
                                          duration: const Duration(seconds: 2),
                                        );
                                      }
                                    },
                                    child: Text(post.isFavorited
                                            ? 'favorites.unfavorite'
                                            : 'favorites.favorite')
                                        .tr(),
                                  )
                                : const SizedBox.shrink();
                          },
                        ),
                        if (post.post.isTranslated)
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
                            child: const Text('post.quick_preview.view_notes')
                                .tr(),
                          ),
                      ],
                    ),
                  ),
                  postAnnotationBuilder?.call(context, post.post, index) ??
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
    case GridSize.normal:
      return SliverPostGridDelegate.normal(spacing, displaySize);
  }
}
