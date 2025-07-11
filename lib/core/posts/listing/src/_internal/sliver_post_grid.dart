// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:i18n/i18n.dart';
import 'package:sliver_masonry_grid/sliver_masonry_grid.dart';

// Project imports:
import '../../../../../foundation/error_monitor.dart';
import '../../../../errors/types.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../../widgets.dart';
import '../utils/grid_utils.dart';
import '../widgets/post_grid_controller.dart';
import 'raw_post_grid.dart';

class SliverPostGrid<T extends Post> extends StatelessWidget {
  const SliverPostGrid({
    required this.postController,
    required this.itemBuilder,
    required this.errorTranslator,
    super.key,
    this.padding,
    this.listType,
    this.size,
    this.spacing,
    this.aspectRatio,
    this.borderRadius,
    this.postsPerPage,
    this.httpErrorActionBuilder,
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

  final Widget Function(BuildContext context, int httpStatusCode)?
  httpErrorActionBuilder;

  final AppErrorTranslator errorTranslator;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: padding ?? EdgeInsets.zero,
      sliver: ValueListenableBuilder(
        valueListenable: postController.errors,
        builder: (_, error, _) {
          if (error != null) {
            final theme = Theme.of(context);

            return SliverToBoxAdapter(
              child: switch (error) {
                final AppError e => ErrorBox(
                  errorMessage: errorTranslator.translateAppError(context, e),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      child: Text(
                        errorTranslator.translateServerError(context, e),
                      ),
                    ),
                    if (httpErrorActionBuilder != null &&
                        e.httpStatusCode != null)
                      httpErrorActionBuilder!(context, e.httpStatusCode!),
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
                                  color: theme.colorScheme.surfaceContainerLow,
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
                        child: Text('Retry'.hc),
                      ),
                  ],
                ),
                final UnknownError e => ErrorBox(
                  errorMessage: e.error.toString(),
                ),
              },
            );
          }

          return ValueListenableBuilder(
            valueListenable: postController.refreshingNotifier,
            builder: (_, refreshing, _) {
              return refreshing
                  ? SliverPostGridPlaceHolder(
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
    final constraints = PostGridConstraints.of(context);

    return SliverPadding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      sliver: ValueListenableBuilder(
        valueListenable: postController.itemsNotifier,
        builder: (_, data, _) {
          final crossAxisCount = calculateGridCount(
            constraints?.maxWidth ?? MediaQuery.sizeOf(context).width,
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
      ),
    );
  }
}

String? translateServerError(BuildContext context, ServerError error) =>
    switch (error) {
      final ServerError e => switch (e.httpStatusCode) {
        null => null,
        401 => context.t.search.errors.forbidden,
        403 => context.t.search.errors.access_denied,
        429 => context.t.search.errors.rate_limited,
        >= 500 => context.t.search.errors.down,
        _ => null,
      },
    };
