// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'trending_tags.dart';

class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(trendingTagsProvider);

    return asyncData.when(
      data: (tags) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(thickness: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'search.trending'.tr().toUpperCase(),
              style: context.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TrendingTags(
            onTagTap: onTagTap,
            tags: tags,
          ),
        ],
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      loading: () => const SizedBox.shrink(),
    );
  }
}
