// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/errors.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/display.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/ui/error_box.dart';
import 'package:boorusama/core/ui/no_data_box.dart';
import 'package:boorusama/core/utils.dart';

class SliverPostGrid extends StatelessWidget {
  final IndexedWidgetBuilder itemBuilder;
  final Settings settings;
  final bool refreshing;
  final BooruError? error;
  final List<Post> data;

  const SliverPostGrid({
    Key? key,
    required this.itemBuilder,
    required this.refreshing,
    required this.error,
    required this.data,
    required this.settings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                appError: (err) {
                  switch (err.type) {
                    case AppErrorType.cannotReachServer:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'Cannot reach server',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.failedToParseJSON:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'API schema changed error',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.unknown:
                      return ErrorBox(errorMessage: message);
                    case AppErrorType.failedToLoadBooruConfig:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'Failed to load booru config',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.booruConfigNotFound:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'Booru config not found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                    case AppErrorType.loadDataFromServerFailed:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 48, bottom: 16),
                            child: Text(
                              'Failed to load data from server',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          Text(message).tr(),
                        ],
                      );
                  }
                },
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

          switch (settings.imageListType) {
            case ImageListType.standard:
              return SliverGrid(
                gridDelegate: gridSizeToGridDelegate(
                  size: settings.gridSize,
                  spacing: settings.imageGridSpacing,
                  screenWidth: MediaQuery.of(context).size.width,
                ),
                delegate: SliverChildBuilderDelegate(
                  itemBuilder,
                  childCount: data.length,
                ),
              );

            case ImageListType.masonry:
              final payload = gridSizeToGridData(
                size: settings.gridSize,
                spacing: settings.imageGridSpacing,
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
    final gridSize =
        context.select((SettingsCubit cubit) => cubit.state.settings.gridSize);

    return usePlaceholder
        ? SliverPostGridPlaceHolder(gridSize: gridSize)
        : const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          );
  }
}

class SliverPostGridPlaceHolder extends StatelessWidget {
  const SliverPostGridPlaceHolder({
    super.key,
    this.gridSize = GridSize.normal,
  });

  final GridSize gridSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.imageBorderRadius !=
              current.settings.imageBorderRadius ||
          previous.settings.imageGridSpacing !=
              current.settings.imageGridSpacing ||
          previous.settings.imageListType != current.settings.imageListType,
      builder: (context, state) {
        switch (state.settings.imageListType) {
          case ImageListType.standard:
            return SliverGrid(
              gridDelegate: gridSizeToGridDelegate(
                size: gridSize,
                spacing: state.settings.imageGridSpacing,
                screenWidth: MediaQuery.of(context).size.width,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(
                        state.settings.imageBorderRadius,
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
              spacing: state.settings.imageGridSpacing,
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
                  borderRadius:
                      BorderRadius.circular(state.settings.imageBorderRadius),
                );
              },
            );
        }
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
