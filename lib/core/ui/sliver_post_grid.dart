// Flutter imports:
import 'package:boorusama/core/application/settings/settings_notifier.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/no_data_box.dart';
import 'package:boorusama/core/utils.dart';

class SliverPostGrid extends ConsumerWidget {
  final IndexedWidgetBuilder itemBuilder;
  final bool refreshing;
  final BooruError? error;
  final List<Post> data;

  const SliverPostGrid({
    Key? key,
    required this.itemBuilder,
    required this.refreshing,
    required this.error,
    required this.data,
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
              child: error?.buildWhen(
                appError: (err) => ErrorBox(errorMessage: message.tr()),
                serverError: (err) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 48, bottom: 16),
                        child: Text(
                          err.httpStatusCode.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(message).tr(),
                    ],
                  ),
                ),
                unknownError: (context) => ErrorBox(errorMessage: message),
              ),
            );
          }

          if (refreshing) {
            return const _Placeholder(usePlaceholder: true);
          }

          if (data.isEmpty) {
            return const SliverToBoxAdapter(child: NoDataBox());
          }

          switch (imageListType) {
            case ImageListType.standard:
              return SliverGrid(
                gridDelegate: gridSizeToGridDelegate(
                  size: gridSize,
                  spacing: imageGridSpacing,
                  screenWidth: MediaQuery.of(context).size.width,
                ),
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: data.length,
                ),
              );

            case ImageListType.masonry:
              final payload = gridSizeToGridData(
                size: gridSize,
                spacing: imageGridSpacing,
                screenWidth: MediaQuery.of(context).size.width,
              );
              final crossAxisCount = payload.first;
              final mainAxisSpacing = payload[1];
              final crossAxisSpacing = payload[2];

              return SliverMasonryGrid.count(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: mainAxisSpacing,
                crossAxisSpacing: crossAxisSpacing,
                childCount: data.length,
                itemBuilder: itemBuilder,
              );
          }
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

    switch (imageListType) {
      case ImageListType.standard:
        return SliverGrid(
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
        );
      case ImageListType.masonry:
        final data = gridSizeToGridData(
          size: gridSize,
          spacing: imageGridSpacing,
          screenWidth: MediaQuery.of(context).size.width,
        );
        final crossAxisCount = data.first;
        final mainAxisSpacing = data[1];
        final crossAxisSpacing = data[2];

        return SliverMasonryGrid.count(
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
        );
    }
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

List<dynamic> gridSizeToGridData({
  required GridSize size,
  required double spacing,
  required double screenWidth,
}) {
  final displaySize = screenWidthToDisplaySize(screenWidth);
  switch (size) {
    case GridSize.large:
      return [displaySizeToGridCountWeight(displaySize), spacing, spacing];
    case GridSize.normal:
      return [displaySizeToGridCountWeight(displaySize) * 2, spacing, spacing];
    case GridSize.small:
      return [displaySizeToGridCountWeight(displaySize) * 3, spacing, spacing];
  }
}
