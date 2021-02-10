// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

class TagChipsPlaceholder extends StatelessWidget {
  const TagChipsPlaceholder({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 8.0),
      height: 50,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: SizedBox(width: Random().nextInt(40).toDouble() + 40),
              selected: false,
              padding: EdgeInsets.all(4.0),
              labelPadding: EdgeInsets.all(1.0),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
