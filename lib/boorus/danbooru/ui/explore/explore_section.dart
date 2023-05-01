// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

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
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: TextButton(
            onPressed: onPressed,
            child: Text(
              'explore.see_more',
              style: Theme.of(context).textTheme.labelLarge,
            ).tr(),
          ),
        ),
        builder(context),
      ],
    );
  }
}
