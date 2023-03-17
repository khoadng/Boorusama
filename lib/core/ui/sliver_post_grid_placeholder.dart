// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/core/application/settings/settings.dart';
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';

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
