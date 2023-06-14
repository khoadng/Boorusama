// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/flutter.dart';

class ExploreSliverAppBar extends StatelessWidget {
  const ExploreSliverAppBar({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text(
        title,
        style:
            context.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w700),
      ),
      floating: true,
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: context.theme.scaffoldBackgroundColor,
    );
  }
}
