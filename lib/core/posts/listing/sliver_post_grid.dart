// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

typedef PostWidgetBuilder<T extends Post> = Widget Function(
  BuildContext context,
  int index,
  T post,
);

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    super.key,
    required this.constraints,
    required this.itemBuilder,
    required this.error,
    required this.multiSelectController,
    required this.postController,
  });

  final BoxConstraints? constraints;
  final PostWidgetBuilder<T> itemBuilder;
  final BooruError? error;
  final MultiSelectController<T>? multiSelectController;
  final PostGridController<T> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGridPadding = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridPadding));
    final colorScheme = Theme.of(context).colorScheme;

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      sliver: Builder(
        builder: (context) {
          final err = error;

          if (err != null) {
            final message = translateBooruError(err);

            return SliverToBoxAdapter(
              child: switch (err) {
                AppError _ => ErrorBox(
                    errorMessage: message.tr(),
                    onRetry: _onErrorRetry,
                  ),
                final ServerError e => Column(
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        e.httpStatusCode.toString(),
                        style: context.textTheme.headlineMedium?.copyWith(
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
                                  prettyPrintJson(e.message));

                              return MarkdownBody(
                                styleSheet: MarkdownStyleSheet(
                                  codeblockPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 8,
                                  ),
                                  codeblockDecoration: BoxDecoration(
                                    //FIXME: change this to surfaceContainerLow
                                    color: colorScheme.secondaryContainer,
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
                  ? _Placeholder(
                      usePlaceholder: true,
                      constraints: constraints,
                    )
                  : _buildGrid(ref, context);
            },
          );
        },
      ),
    );
  }

  void _onErrorRetry() => postController.refresh();

  Widget _buildGrid(WidgetRef ref, BuildContext context) {
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageGridAspectRatio));

    return ValueListenableBuilder(
      valueListenable: postController.itemsNotifier,
      builder: (_, data, __) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? context.screenWidth,
          gridSize,
        );

        return data.isNotEmpty
            ? switch (imageListType) {
                ImageListType.standard => SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: imageGridAspectRatio,
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: imageGridSpacing,
                      crossAxisSpacing: imageGridSpacing,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => buildItem(context, index, data),
                      childCount: data.length,
                    ),
                  ),
                ImageListType.masonry => SliverMasonryGrid.count(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: imageGridSpacing,
                    crossAxisSpacing: imageGridSpacing,
                    childCount: data.length,
                    itemBuilder: (context, index) =>
                        buildItem(context, index, data),
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

  Widget buildItem(context, index, List<T> data) {
    final controller = multiSelectController;
    final post = data[index];

    if (controller == null) {
      return itemBuilder(context, index, post);
    }

    return ValueListenableBuilder(
      valueListenable: controller.multiSelectNotifier,
      builder: (_, multiSelect, __) => multiSelect
          ? ValueListenableBuilder(
              valueListenable: controller.selectedItemsNotifier,
              builder: (_, selectedItems, __) => SelectableItem(
                index: index,
                isSelected: selectedItems.contains(post),
                onTap: () => controller.toggleSelection(post),
                itemBuilder: (context, isSelected) =>
                    itemBuilder(context, index, post),
              ),
            )
          : itemBuilder(context, index, post),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.usePlaceholder,
    this.constraints,
  });

  final bool usePlaceholder;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return usePlaceholder
        ? SliverPostGridPlaceHolder(
            constraints: constraints,
          )
        : const SliverSizedBox.shrink();
  }
}

class SliverPostGridPlaceHolder extends ConsumerWidget {
  const SliverPostGridPlaceHolder({
    super.key,
    this.constraints,
  });

  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageBorderRadius = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageBorderRadius));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageGridAspectRatio));

    return Builder(
      builder: (context) {
        final crossAxisCount = calculateGridCount(
          constraints?.maxWidth ?? context.screenWidth,
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
                (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        imageBorderRadius,
                      ),
                    ),
                  );
                },
                childCount: 100,
              ),
            ),
          ImageListType.masonry => SliverMasonryGrid.count(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: imageGridSpacing,
              crossAxisSpacing: imageGridSpacing,
              childCount: 100,
              itemBuilder: (context, index) {
                return createRandomPlaceholderContainer(
                  context,
                  borderRadius: BorderRadius.circular(imageBorderRadius),
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
