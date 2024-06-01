// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BooruScrollToTopButton extends StatelessWidget {
  const BooruScrollToTopButton({
    super.key,
    this.onPressed,
  });

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      child: const FaIcon(
        FontAwesomeIcons.angleUp,
        size: 18,
      ),
    );
  }
}
