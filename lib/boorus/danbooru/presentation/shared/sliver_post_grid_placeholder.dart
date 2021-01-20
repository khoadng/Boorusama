import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class SliverPostGridPlaceHolder extends StatelessWidget {
  const SliverPostGridPlaceHolder({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 5.0),
      sliver: SliverStaggeredGrid.countBuilder(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            highlightColor: Colors.grey[800],
            baseColor: Theme.of(context).cardColor,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        },
        staggeredTileBuilder: (index) {
          return StaggeredTile.extent(
              1, MediaQuery.of(context).size.height * 0.3);
        },
      ),
    );
  }
}
