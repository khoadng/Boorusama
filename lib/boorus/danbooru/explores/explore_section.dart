// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:foundation/foundation.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.title,
    required this.builder,
    required this.onPressed,
  });

  final Widget Function(BuildContext context) builder;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: onPressed != null
              ? TextButton(
                  onPressed: onPressed,
                  child: Text(
                    'explore.see_more',
                    style: Theme.of(context).textTheme.labelLarge,
                  ).tr(),
                )
              : null,
        ),
        builder(context),
      ],
    );
  }
}
