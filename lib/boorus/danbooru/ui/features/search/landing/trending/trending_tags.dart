import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrendingTags extends StatelessWidget {
  const TrendingTags({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context) {
    final tags = context.select((SearchKeywordCubit cubit) => cubit.state.data);

    return tags != null && tags.isNotEmpty
        ? Wrap(
            spacing: 4,
            runSpacing: -4,
            children: tags
                .take(15)
                .map((e) => GestureDetector(
                      onTap: () => onTagTap?.call(e.keyword),
                      child: Chip(
                        label: Text(
                          e.keyword.replaceAll('_', ' '),
                        ),
                      ),
                    ))
                .toList(),
          )
        : const SizedBox.shrink();
  }
}
