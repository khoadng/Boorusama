// Flutter imports:
import 'package:boorusama/core/core.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tag/most_searched_tag_cubit.dart';

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
            runSpacing: isMobilePlatform() ? -4 : 8,
            children: tags
                .take(15)
                .map((e) => RawChip(
                      onPressed: () => onTagTap?.call(e.keyword),
                      label: Text(
                        e.keyword.replaceAll('_', ' '),
                      ),
                    ))
                .toList(),
          )
        : const SizedBox.shrink();
  }
}
