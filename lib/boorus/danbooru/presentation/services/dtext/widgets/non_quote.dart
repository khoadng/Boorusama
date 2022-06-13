// Flutter imports:
import 'package:flutter/material.dart';

class NonQuote extends StatelessWidget {
  const NonQuote({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.start,
    );
  }
}
