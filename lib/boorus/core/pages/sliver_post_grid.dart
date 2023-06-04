// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/core/feat/posts/posts.dart';
import 'package:boorusama/boorus/core/feat/settings/settings.dart';
import 'package:boorusama/boorus/core/pages/error_box.dart';
import 'package:boorusama/boorus/core/pages/no_data_box.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/i18n.dart';

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
                            style: Theme.of(context).textTheme.headlineMedium,
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

          final payload = gridSizeToGridData(
            size: gridSize,
            spacing: imageGridSpacing,
            screenWidth: MediaQuery.of(context).size.width,
          );
          final crossAxisCount = payload.$1;
          final mainAxisSpacing = payload.$2;
          final crossAxisSpacing = payload.$3;

          return switch (imageListType) {
            ImageListType.standard => SliverGrid(
                gridDelegate: gridSizeToGridDelegate(
                  size: gridSize,
                  spacing: imageGridSpacing,
                  screenWidth: MediaQuery.of(context).size.width,
                ),
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: data.length,
                ),
              ),
            ImageListType.masonry => SliverMasonryGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
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
        : const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
  }
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

    final data = gridSizeToGridData(
      size: gridSize,
      spacing: imageGridSpacing,
      screenWidth: MediaQuery.of(context).size.width,
    );
    final crossAxisCount = data.$1;
    final mainAxisSpacing = data.$2;
    final crossAxisSpacing = data.$3;

    return switch (imageListType) {
      ImageListType.standard => SliverGrid(
          gridDelegate: gridSizeToGridDelegate(
            size: gridSize,
            spacing: imageGridSpacing,
            screenWidth: MediaQuery.of(context).size.width,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, _) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
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
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
          childCount: 100,
          itemBuilder: (context, index) {
            return createRandomPlaceholderContainer(
              context,
              borderRadius: BorderRadius.circular(imageBorderRadius),
            );
          },
        )
    };
  }
}

SliverGridDelegate gridSizeToGridDelegate({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  return switch (size) {
    GridSize.large => SliverPostGridDelegate.large(spacing, displaySize),
    GridSize.small => SliverPostGridDelegate.small(spacing, displaySize),
    GridSize.normal => SliverPostGridDelegate.normal(spacing, displaySize)
  };
}

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

int displaySizeToGridCountWeight(ScreenSize size) => switch (size) {
      ScreenSize.small => 1,
      ScreenSize.medium => 2,
      ScreenSize.large || ScreenSize.veryLarge => 3,
    };

(
  int crossAxisCount,
  double mainAxisSpacing,
  double crossAxisSpacing,
) gridSizeToGridData({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  return switch (size) {
    GridSize.large => (
        displaySizeToGridCountWeight(displaySize),
        spacing,
        spacing
      ),
    GridSize.normal => (
        displaySizeToGridCountWeight(displaySize) * 2,
        spacing,
        spacing
      ),
    GridSize.small => (
        displaySizeToGridCountWeight(displaySize) * 3,
        spacing,
        spacing
      ),
  };
}
