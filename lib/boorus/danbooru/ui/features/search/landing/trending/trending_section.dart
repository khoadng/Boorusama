import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'trending_tags.dart';

class TrendingSection extends StatelessWidget {
  const TrendingSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final status =
        context.select((SearchKeywordCubit cubit) => cubit.state.status);

    return status != LoadStatus.success
        ? const Center(child: CircularProgressIndicator.adaptive())
        : TrendingTags(onTagTap: onTagTap);
  }
}
