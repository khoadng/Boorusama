// Flutter imports:
import 'package:flutter/material.dart';

class EditorSpacer extends StatelessWidget {
  const EditorSpacer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      width: double.infinity,
      height: 1,
      color: Theme.of(context).dividerColor,
    );
  }
}
