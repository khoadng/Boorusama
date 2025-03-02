// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:foundation/foundation.dart';
import 'package:sliver_masonry_grid/sliver_masonry_grid.dart';

// Project imports:
import '../../../../../boorus/danbooru/errors.dart';
import '../../../../foundation/error.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../utils/grid_utils.dart';
import '../widgets/post_grid_controller.dart';
import '../widgets/sliver_post_grid_place_holder.dart';

class SliverPostGrid<T extends Post> extends StatelessWidget {
  const SliverPostGrid({
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

          return SliverLayoutBuilder(
            builder: (context, constraints) {
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
                      : _buildGrid(context, constraints);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _onErrorRetry() => postController.refresh();

  Widget _buildGrid(
    BuildContext context,
    SliverConstraints? constraints,
  ) {
    return ValueListenableBuilder(
      valueListenable: postController.itemsNotifier,
      builder: (_, data, __) {
        final crossAxisCount = calculateGridCount(
          constraints?.crossAxisExtent ?? MediaQuery.sizeOf(context).width,
          size ?? GridSize.normal,
        );
        final imageListType = listType ?? ImageListType.standard;

        return data.isNotEmpty
            ? switch (imageListType) {
                ImageListType.masonry => SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: spacing ?? 4,
                    crossAxisSpacing: spacing ?? 4,
                    childCount: data.length,
                    itemBuilder: itemBuilder,
                  ),
                _ => SliverGrid(
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
