// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/presentation/shared/shared.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

class SliverPostGridPlaceHolder extends StatelessWidget {
  const SliverPostGridPlaceHolder({
    Key? key,
    this.gridSize = GridSize.normal,
  }) : super(key: key);

  final GridSize gridSize;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.imageBorderRadius !=
              current.settings.imageBorderRadius ||
          previous.settings.imageGridSpacing !=
              current.settings.imageGridSpacing,
      builder: (context, state) {
        return SliverGrid(
          gridDelegate: gridSizeToGridDelegate(
            gridSize,
            state.settings.imageGridSpacing,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, _) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(state.settings.imageBorderRadius),
                ),
              );
            },
            childCount: 20,
          ),
        );
      },
    );
  }
}
