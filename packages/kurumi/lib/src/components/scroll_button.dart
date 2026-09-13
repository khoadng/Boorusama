import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class KurumiScrollToTopButton extends StatelessWidget {
  const KurumiScrollToTopButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

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

class KurumiScrollToBottomButton extends StatelessWidget {
  const KurumiScrollToBottomButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: null,
      onPressed: onPressed,
      child: const FaIcon(
        FontAwesomeIcons.angleDown,
        size: 18,
      ),
    );
  }
}
