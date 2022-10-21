// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

class ArtistCommentaryPlaceholder extends StatelessWidget {
  const ArtistCommentaryPlaceholder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: const CircleAvatar(),
          title: Container(
            margin: EdgeInsets.only(right: width * 0.4),
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
        ...List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            width: width * 0.1 + Random().nextDouble() * width * 0.9,
            height: 20,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
