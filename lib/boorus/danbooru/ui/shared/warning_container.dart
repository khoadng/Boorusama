// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WarningContainer extends StatelessWidget {
  const WarningContainer({
    super.key,
    required this.contentBuilder,
  });

  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Theme.of(context).colorScheme.error,
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: FaIcon(FontAwesomeIcons.triangleExclamation),
            ),
            Expanded(child: contentBuilder(context)),
          ],
        ),
      ),
    );
  }
}
