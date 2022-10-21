// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    Key? key,
    required this.contentBuilder,
  }) : super(key: key);

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
        color: Theme.of(context).cardColor,
      ),
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: FaIcon(
                FontAwesomeIcons.lightbulb,
                color: Colors.amber,
              ),
            ),
            Expanded(child: contentBuilder(context)),
          ],
        ),
      ),
    );
  }
}
