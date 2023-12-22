// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';

class WarningContainer extends StatelessWidget {
  const WarningContainer({
    super.key,
    this.margin,
    required this.contentBuilder,
  });
  final EdgeInsetsGeometry? margin;

  final Widget Function(BuildContext context) contentBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: Theme.of(context).colorScheme.error,
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FaIcon(
                FontAwesomeIcons.triangleExclamation,
                color: context.colorScheme.onError,
              ),
            ),
            Expanded(
              child: contentBuilder(context),
            ),
          ],
        ),
      ),
    );
  }
}
