// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WarningContainer extends StatelessWidget {
  const WarningContainer({
    Key? key,
    required this.contentBuilder,
  }) : super(key: key);

  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }
}

class InfoContainer extends StatelessWidget {
  const InfoContainer({
    Key? key,
    required this.contentBuilder,
  }) : super(key: key);

  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
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
      ),
    );
  }
}
