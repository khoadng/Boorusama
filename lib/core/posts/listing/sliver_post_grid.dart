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
import 'package:boorusama/widgets/sliver_sized_box.dart';

class SliverPostGrid extends ConsumerWidget {
  const SliverPostGrid({
    super.key,
    required this.itemBuilder,
    required this.refreshing,
    required this.error,
    required this.data,
    required this.onRetry,
    this.constraints,
  });

  final IndexedWidgetBuilder itemBuilder;
  final bool refreshing;
  final BooruError? error;
  final Iterable<Post> data;
  final VoidCallback? onRetry;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageListType));
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridSpacing));
    final imageGridPadding = ref.watch(
        imageListingSettingsProvider.select((value) => value.imageGridPadding));
    final imageGridAspectRatio = ref.watch(imageListingSettingsProvider
        .select((value) => value.imageGridAspectRatio));

    return SliverPadding(
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      sliver: Builder(
        builder: (context) {
          if (error != null) {
            final message = translateBooruError(error!);

            return SliverToBoxAdapter(
              child: switch (error!) {
                AppError _ => ErrorBox(
                    errorMessage: message.tr(),
                    onRetry: onRetry,
                  ),
                ServerError e => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 48, bottom: 16),
                          child: Text(
                            e.httpStatusCode.toString(),
                            style: context.textTheme.headlineMedium,
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            try {
                              final data = wrapIntoJsonToCodeBlock(
                                  prettyPrintJson(e.message));

                              return MarkdownBody(
                                shrinkWrap: true,
                                data: data,
                              );
                            } catch (err) {
                              return Text(
                                e.message.toString(),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        if (e.isServerError)
                          FilledButton(
                            onPressed: onRetry,
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  ),
                UnknownError _ => ErrorBox(errorMessage: message),
              },
            );
          }

          if (refreshing) {
            return _Placeholder(
              usePlaceholder: true,
              constraints: constraints,
            );
          }

          if (data.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 48),
                child: NoDataBox(),
              ),
            );
          }

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
                  itemBuilder,
                  childCount: data.length,
                ),
              ),
            ImageListType.masonry => SliverMasonryGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: imageGridSpacing,
                crossAxisSpacing: imageGridSpacing,
                childCount: data.length,
                itemBuilder: itemBuilder,
              ),
          };
        },
      ),
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
