// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class SliverPostGrid extends ConsumerWidget {
  final IndexedWidgetBuilder itemBuilder;
  final bool refreshing;
  final BooruError? error;
  final List<Post> data;
  final VoidCallback? onRetry;

  const SliverPostGrid({
    Key? key,
    required this.itemBuilder,
    required this.refreshing,
    required this.error,
    required this.data,
    required this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = ref.watch(imageListTypeSettingsProvider);
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageGridSpacing = ref.watch(gridSpacingSettingsProvider);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
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
                        Text(message).tr(),
                        const SizedBox(height: 16),
                        if (e.isServerError)
                          ElevatedButton(
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
            return const _Placeholder(usePlaceholder: true);
          }

          if (data.isEmpty) {
            return const SliverToBoxAdapter(child: NoDataBox());
          }

          final crossAxisCount = calculateGridCount(context, gridSize);

          return switch (imageListType) {
            ImageListType.standard => SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  childAspectRatio: 0.65,
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
  });

  final bool usePlaceholder;

  @override
  Widget build(BuildContext context) {
    return usePlaceholder
        ? const SliverPostGridPlaceHolder()
        : const SliverSizedBox.shrink();
  }
}

int calculateGridCount(BuildContext context, GridSize size) {
  final screenWidth = context.screenWidth;
  final displaySize = screenWidthToDisplaySize(screenWidth);
  final weight = displaySizeToGridCountWeight(displaySize);

  final count = switch (size) {
    GridSize.small => 2.5 * weight,
    GridSize.normal => 1.5 * weight,
    GridSize.large => 1 * weight,
  };

  return count.toInt();
}

class SliverPostGridPlaceHolder extends ConsumerWidget {
  const SliverPostGridPlaceHolder({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageListType = ref.watch(imageListTypeSettingsProvider);
    final gridSize = ref.watch(gridSizeSettingsProvider);
    final imageGridSpacing = ref.watch(gridSpacingSettingsProvider);
    final imageBorderRadius = ref.watch(imageBorderRadiusSettingsProvider);

    return Builder(
      builder: (context) {
        final crossAxisCount = calculateGridCount(context, gridSize);

        return switch (imageListType) {
          ImageListType.standard => SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 0.65,
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: imageGridSpacing,
                crossAxisSpacing: imageGridSpacing,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: context.theme.cardColor,
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

int displaySizeToGridCountWeight(ScreenSize size) => switch (size) {
      ScreenSize.small => 1,
      ScreenSize.medium => 2,
      ScreenSize.large => 3,
      ScreenSize.veryLarge => 4,
    };
