// Flutter imports:
import 'package:flutter/material.dart';

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
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.w700),
      ),
      floating: true,
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    );
  }
}
