// Flutter imports:
import 'package:flutter/material.dart';

class Quote extends StatelessWidget {
  final String text;
  const Quote({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xff393a4d),
          border: Border.all(
            color: Color(0xff7b7c8e),
            width: 3,
          )),
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(text),
    );
  }
}
