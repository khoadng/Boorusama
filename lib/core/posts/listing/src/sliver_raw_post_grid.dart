// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../boorus/danbooru/errors.dart';
import '../../../foundation/error.dart';
import '../../../images/booru_image.dart';
import '../../../images/utils.dart';
import '../../../settings/settings.dart';
import '../../../widgets/widgets.dart';
import '../../post/post.dart';
import 'grid_utils.dart';
import 'post_grid_controller.dart';

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
