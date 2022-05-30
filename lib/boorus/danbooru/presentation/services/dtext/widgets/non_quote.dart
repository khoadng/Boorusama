// Flutter imports:
import 'package:flutter/material.dart';

class NonQuote extends StatelessWidget {
  final String text;
  const NonQuote({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
    );
  }
}
