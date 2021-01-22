import 'package:auto_animated/auto_animated.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SliverPostGridPlaceHolder extends StatelessWidget {
  const SliverPostGridPlaceHolder({
    Key key,
    @required this.scrollController,
  }) : super(key: key);

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return LiveSliverGrid(
      itemBuilder: (context, index, animation) {
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
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 20,
      controller: scrollController,
    );
  }
}
