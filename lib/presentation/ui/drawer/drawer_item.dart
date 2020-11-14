import 'package:flutter/material.dart';

class DrawerItem extends StatelessWidget {
  final String text;
  final Function onPressed;
  final Widget leading;

  const DrawerItem({
    Key key,
    this.text,
    this.onPressed,
    this.leading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
          leading: leading,
          onTap: onPressed,
          title: Text(
            text,
          )),
    );
  }
}
