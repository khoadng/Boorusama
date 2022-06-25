// Flutter imports:
import 'package:flutter/material.dart';

class PreviewPostGridPlaceHolder extends StatelessWidget {
  const PreviewPostGridPlaceHolder({
    Key? key,
    required this.itemCount,
    this.physics,
  }) : super(key: key);

  final ScrollPhysics? physics;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.3,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
