// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/tags.dart';
import 'package:boorusama/core/core.dart';

class TrendingTags extends StatelessWidget {
  const TrendingTags({
    super.key,
    required this.onTagTap,
    required this.tags,
  });

  final ValueChanged<String>? onTagTap;
  final List<Search>? tags;

  @override
  Widget build(BuildContext context) {
    return tags != null && tags!.isNotEmpty
        ? Wrap(
            spacing: 4,
            runSpacing: isMobilePlatform() ? -4 : 8,
            children: tags!
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
