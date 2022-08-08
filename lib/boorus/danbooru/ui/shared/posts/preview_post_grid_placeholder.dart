// Flutter imports:
import 'package:flutter/material.dart';

class PreviewPostGridPlaceHolder extends StatelessWidget {
  const PreviewPostGridPlaceHolder({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator.adaptive(),
    );
  }
}
