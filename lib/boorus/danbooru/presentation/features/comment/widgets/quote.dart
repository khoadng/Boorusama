// Flutter imports:
import 'package:flutter/material.dart';

class Quote extends StatelessWidget {
  const Quote({Key? key, required this.text}) : super(key: key);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xff393a4d),
          border: Border.all(
            color: const Color(0xff7b7c8e),
            width: 3,
          )),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text),
    );
  }
}
