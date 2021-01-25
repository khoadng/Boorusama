// Flutter imports:
import 'package:flutter/material.dart';

class EditorSpacer extends StatelessWidget {
  const EditorSpacer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        height: 1,
        color: Theme.of(context).dividerColor,
      ),
    );
  }
}
