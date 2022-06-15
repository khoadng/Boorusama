// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/presentation/shared/sliver_post_grid.dart';
import 'package:boorusama/core/presentation/grid_size.dart';

class SliverPostGridPlaceHolder extends StatelessWidget {
  const SliverPostGridPlaceHolder({
    Key? key,
    this.gridSize = GridSize.normal,
  }) : super(key: key);

  final GridSize gridSize;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: gridSizeToGridDelegate(gridSize),
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
          );
        },
        childCount: 20,
      ),
    );
  }
}
