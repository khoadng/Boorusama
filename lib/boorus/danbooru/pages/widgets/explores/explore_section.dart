// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.title,
    required this.builder,
    required this.onPressed,
  });

  final Widget Function(BuildContext context) builder;
  final String title;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: context.textTheme.titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: TextButton(
            onPressed: onPressed,
            child: Text(
              'explore.see_more',
              style: context.textTheme.labelLarge,
            ).tr(),
          ),
        ),
        builder(context),
      ],
    );
  }
}
