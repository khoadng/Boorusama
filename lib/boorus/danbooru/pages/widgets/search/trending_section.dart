// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'trending_tags.dart';

final _top20TrendingTagsProvider = FutureProvider.autoDispose
    .family<List<TrendingTag>, BooruConfig>((ref, config) async {
  final tags = await ref.watch(trendingTagsProvider(config).future);

  final trendingTags = <TrendingTag>[];

  for (final tag in tags.take(20)) {
    final cat =
        await ref.watch(danbooruTagCategoryProvider(tag.keyword).future);
    trendingTags.add((
      name: tag,
      category: cat,
    ));
  }

  return trendingTags;
});

typedef TrendingTag = ({
  Search name,
  TagCategory? category,
});

class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ref.watch(_top20TrendingTagsProvider(config)).when(
          data: (tags) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'search.trending'.tr().toUpperCase(),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TrendingTags(
                onTagTap: onTagTap,
                colorBuilder: (context, name) => ref.getTagColor(context, name),
                tags: tags,
              ),
            ],
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => const SizedBox.shrink(),
        );
  }
}
