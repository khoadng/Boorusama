// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'explore_detail_page.dart';

class ExploreSection extends StatelessWidget {
  const ExploreSection({
    Key? key,
    required this.title,
    required this.category,
    required this.builder,
  }) : super(key: key);

  final Widget Function(BuildContext context) builder;
  final String title;
  final ExploreCategory category;

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
              onPressed: () => showBarModalBottomSheet(
                    context: context,
                    builder: (context) => BlocProvider(
                      create: (context) => ExploreDetailBloc(),
                      child: ExploreDetailPage(
                        title: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .headline6!
                              .copyWith(fontWeight: FontWeight.w700),
                        ),
                        category: category,
                      ),
                    ),
                  ),
              child: Text(
                'explore.see_more',
                style: Theme.of(context).textTheme.button,
              ).tr()),
        ),
        builder(context),
      ],
    );
  }
}
