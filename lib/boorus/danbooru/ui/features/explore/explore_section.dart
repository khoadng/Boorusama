// Flutter imports:
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.title,
    required this.category,
    required this.builder,
    this.date,
  });

  final Widget Function(BuildContext context) builder;
  final String title;
  final ExploreCategory category;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: Theme.of(context)
                .textTheme
                .headline6!
                .copyWith(fontWeight: FontWeight.w700),
          ),
          trailing: TextButton(
            onPressed: () =>
                goToExploreDetailPage(context, date, title, category),
            child: Text(
              'explore.see_more',
              style: Theme.of(context).textTheme.button,
            ).tr(),
          ),
        ),
        builder(context),
      ],
    );
  }
}
