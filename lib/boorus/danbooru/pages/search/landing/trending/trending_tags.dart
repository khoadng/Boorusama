// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/tags/tags.dart';
import 'package:boorusama/foundation/platform.dart';

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
