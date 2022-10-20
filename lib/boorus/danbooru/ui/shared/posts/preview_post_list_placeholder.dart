// Flutter imports:
import 'package:flutter/material.dart';

class PreviewPostListPlaceHolder extends StatelessWidget {
  const PreviewPostListPlaceHolder({
    Key? key,
    required this.itemCount,
    this.physics,
  }) : super(key: key);

  final ScrollPhysics? physics;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      itemCount: itemCount,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(3),
        height: MediaQuery.of(context).size.height * 0.2,
        width: MediaQuery.of(context).size.width * 0.3,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),
        ),
      ),
    );
  }
}
