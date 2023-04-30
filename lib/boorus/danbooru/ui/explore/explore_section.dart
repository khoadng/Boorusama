// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/router.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    super.key,
    required this.title,
    required this.category,
    required this.builder,
    this.date,
    required this.controller,
  });

  final Widget Function(BuildContext context) builder;
  final String title;
  final ExploreCategory category;
  final DateTime? date;
  final PostGridController<DanbooruPost> controller;

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
            onPressed: () => goToExploreDetailPage(
                context, date, title, category, controller),
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
