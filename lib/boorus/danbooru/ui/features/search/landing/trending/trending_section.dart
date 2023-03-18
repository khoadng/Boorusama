// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/trending_tag_cubit.dart';
import 'package:boorusama/core/application/common.dart';
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
        context.select((TrendingTagCubit cubit) => cubit.state.status);

    return status != LoadStatus.success
        ? const Center(child: CircularProgressIndicator.adaptive())
        : TrendingTags(onTagTap: onTagTap);
  }
}
