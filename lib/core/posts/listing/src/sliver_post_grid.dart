// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../boorus/danbooru/errors.dart';
import '../../../configs/config.dart';
import '../../../foundation/error.dart';
import '../../../images/booru_image.dart';
import '../../../images/utils.dart';
import '../../../settings/providers.dart';
import '../../../settings/settings.dart';
import '../../post/post.dart';
import '../../post/tags.dart';
import '../../post/widgets.dart';
import 'grid_utils.dart';
import 'post_grid_controller.dart';

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    required this.constraints,
    required this.itemBuilder,
    required this.postController,
    super.key,
  });

  final BoxConstraints? constraints;
  final IndexedWidgetBuilder itemBuilder;
  final PostGridController<T> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridPadding),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridAspectRatio = ref.watch(
      imageListingSettingsProvider
          .select((value) => value.imageGridAspectRatio),
    );
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );

    return SliverRawPostGrid(
      constraints: constraints,
      itemBuilder: itemBuilder,
      postController: postController,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      size: gridSize,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      postsPerPage: postsPerPage,
    );
  }
}

class SliverRawPostGrid<T extends Post> extends StatelessWidget {
  const SliverRawPostGrid({
    required this.constraints,
    required this.postController,
    required this.itemBuilder,
    super.key,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
    this.postsPerPage,
  });

  final BoxConstraints? constraints;
  final PostGridController<T> postController;
  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final GridSize? size;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final int? postsPerPage;

  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: ValueListenableBuilder(
        valueListenable: postController.errors,
        builder: (_, error, __) {
          if (error != null) {
            final message = translateBooruError(error);
            final theme = Theme.of(context);

            return SliverToBoxAdapter(
              child: switch (error) {
                AppError _ => ErrorBox(
                    errorMessage: message.tr(),
                    onRetry: _onErrorRetry,
                  ),
                final ServerError e => Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        e.httpStatusCode.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final serverError = translateServerError(e);

                          return serverError != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(serverError.tr()),
                                )
                              : const SizedBox.shrink();
                        },
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: e.isServerError ? 4 : 24,
                        ),
                        child: Builder(
                          builder: (context) {
                            try {
                              final data = wrapIntoJsonToCodeBlock(
                                prettyPrintJson(e.message),
                              );

                              return MarkdownBody(
                                styleSheet: MarkdownStyleSheet(
                                  codeblockPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    color:
                                        theme.colorScheme.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                data: data,
                              );
                            } catch (err) {
                              return Text(
                                e.message.toString(),
                              );
                            }
                          },
                        ),
                      ),
                      if (e.isServerError)
                        FilledButton(
                          onPressed: _onErrorRetry,
                          child: const Text('Retry'),
                        ),
                    ],
                  ),
                UnknownError _ => ErrorBox(errorMessage: message),
              },
            );
          }

          return ValueListenableBuilder(
            valueListenable: postController.refreshingNotifier,
            builder: (_, refreshing, __) {
              return refreshing
                  ? SliverPostGridPlaceHolder(
                      constraints: constraints,
                      padding: padding,
                      listType: listType,
                      size: size,
                      spacing: spacing,
                      aspectRatio: aspectRatio,
                      borderRadius: borderRadius,
                      postsPerPage: postsPerPage,
                    )
                  : _buildGrid(context);
            },
          );
        },
      ),
    );
  }

  void _onErrorRetry() => postController.refresh();

  Widget _buildGrid(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: postController.itemsNotifier,
      builder: (_, data, __) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? MediaQuery.sizeOf(context).width,
          size ?? GridSize.normal,
        );
        final imageListType = listType ?? ImageListType.standard;

        return data.isNotEmpty
            ? switch (imageListType) {
                ImageListType.standard => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: aspectRatio ?? 1,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: spacing ?? 4,
                      crossAxisSpacing: spacing ?? 4,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      itemBuilder,
                      childCount: data.length,
                    ),
                  ),
                ImageListType.masonry => SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing ?? 4,
                    crossAxisSpacing: spacing ?? 4,
                    childCount: data.length,
                    itemBuilder: itemBuilder,
                  ),
              }
            : const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: NoDataBox(),
                ),
              );
      },
    );
  }
}

class SliverPostGridPlaceHolder extends ConsumerWidget {
  const SliverPostGridPlaceHolder({
    super.key,
    this.constraints,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
    this.postsPerPage,
  });

  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? padding;
  final ImageListType? listType;
  final GridSize? size;
  final double? spacing;
  final double? aspectRatio;
  final BorderRadius? borderRadius;
  final int? postsPerPage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = listType ?? ImageListType.standard;
    final gridSize = size ?? GridSize.normal;
    final imageGridSpacing = spacing ?? 4;
    final imageBorderRadius = borderRadius ?? BorderRadius.zero;
    final imageGridAspectRatio = aspectRatio ?? 1;
    final perPage = postsPerPage ?? 20;

    return Builder(
      builder: (context) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? MediaQuery.sizeOf(context).width,
          gridSize,
        );

        return switch (imageListType) {
          ImageListType.standard => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: imageGridAspectRatio,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: imageGridSpacing,
                crossAxisSpacing: imageGridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _) => ImagePlaceHolder(
                  borderRadius: imageBorderRadius,
                ),
                childCount: perPage,
                addRepaintBoundaries: false,
                addAutomaticKeepAlives: false,
                addSemanticIndexes: false,
              ),
            ),
          ImageListType.masonry => SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: imageGridSpacing,
              crossAxisSpacing: imageGridSpacing,
              childCount: perPage,
              addRepaintBoundaries: false,
              addAutomaticKeepAlives: false,
              addSemanticIndexes: false,
              itemBuilder: (context, index) {
                return createRandomPlaceholderContainer(
                  context,
                  borderRadius: imageBorderRadius,
                );
              },
            )
        };
      },
    );
  }
}

class BlockOverlayItem {
  const BlockOverlayItem({
    required this.overlay,
    this.onTap,
  });

  final VoidCallback? onTap;
  final Widget overlay;
}

class SliverPostGridImageGridItem<T extends Post> extends ConsumerWidget {
  const SliverPostGridImageGridItem({
    required this.post,
    required this.hideOverlay,
    required this.quickActionButton,
    required this.autoScrollOptions,
    required this.onTap,
    required this.image,
    required this.score,
    super.key,
    this.blockOverlay,
  });

  final T post;
  final bool hideOverlay;
  final Widget? quickActionButton;
  final AutoScrollOptions? autoScrollOptions;
  final VoidCallback? onTap;
  final Widget image;
  final int? score;
  final BlockOverlayItem? blockOverlay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );
    final showScoresInGrid = ref.watch(
      imageListingSettingsProvider.select((value) => value.showScoresInGrid),
    );

    final overlay = blockOverlay;

    return Stack(
      children: [
        ImageGridItem(
          borderRadius: BorderRadius.circular(imageBorderRadius),
          isGif: post.isGif,
          isAI: post.isAI,
          hideOverlay: hideOverlay,
          quickActionButton: quickActionButton,
          autoScrollOptions: autoScrollOptions,
          onTap: onTap,
          image: image,
          isAnimated: post.isAnimated,
          isTranslated: post.isTranslated,
          hasComments: post.hasComment,
          hasParentOrChildren: post.hasParentOrChildren,
          hasSound: post.hasSound,
          duration: post.duration,
          score: showScoresInGrid ? score : null,
        ),
        if (overlay != null) ...[
          Positioned.fill(
            child: InkWell(
              highlightColor: Colors.transparent,
              splashFactory: FasterInkSplash.splashFactory,
              splashColor: Colors.black38,
              onTap: blockOverlay?.onTap,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: overlay.overlay,
            ),
          ),
        ],
      ],
    );
  }
}

class DefaultPostListContextMenuRegion extends StatelessWidget {
  const DefaultPostListContextMenuRegion({
    required this.gestures,
    required this.contextMenu,
    required this.child,
    super.key,
    this.isEnabled = true,
  });

  final GestureConfig? gestures;
  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (gestures.canLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}

String? translateServerError(ServerError error) => switch (error) {
      final ServerError e => switch (e.httpStatusCode) {
          null => null,
          401 => 'search.errors.forbidden',
          403 => 'search.errors.access_denied',
          429 => 'search.errors.rate_limited',
          >= 500 => 'search.errors.down',
          _ => null,
        },
    };
