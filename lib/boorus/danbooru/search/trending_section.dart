// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/tags/tags.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'trending_tags.dart';

final _kTrendingTagCount = 15;

final _top15TrendingTagsProvider = FutureProvider.autoDispose
    .family<List<TrendingTag>, BooruConfig>((ref, config) async {
  final tags = await ref.watch(trendingTagsProvider(config).future);

  final trendingTags = <TrendingTag>[];

  for (final tag in tags.take(_kTrendingTagCount)) {
    final cat =
        await ref.watch(danbooruTagCategoryProvider(tag.keyword).future);
    trendingTags.add(TrendingTag(
      name: tag,
      category: cat,
    ));
  }

  return trendingTags;
});

final _top15PlaceholderTagsProvider = Provider<List<TrendingTag>>((ref) {
  final tags = <TrendingTag>[];
  final rnd = Random();
  final minChar = 6;
  final maxChar = 20;

  for (var i = 0; i < _kTrendingTagCount; i++) {
    final sb = StringBuffer();
    final length = minChar + rnd.nextInt(maxChar - minChar);
    for (var j = 0; j < length; j++) {
      sb.write('a');
    }

    tags.add(TrendingTag(
      name: Search(keyword: sb.toString(), hitCount: 1),
    ));
  }

  return tags;
});

class TrendingTag extends Equatable {
  const TrendingTag({
    required this.name,
    this.category,
  });

  final Search name;
  final TagCategory? category;

  @override
  List<Object?> get props => [name, category];
}

class TrendingSection extends ConsumerWidget {
  const TrendingSection({
    super.key,
    required this.onTagTap,
  });

  final ValueChanged<String>? onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watchConfig;

    return ref.watch(_top15TrendingTagsProvider(config)).when(
          data: (tags) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              TrendingTags(
                onTagTap: onTagTap,
                colorBuilder: (context, name) =>
                    ref.watch(tagColorProvider(name)),
                tags: tags,
              ),
            ],
          ),
          error: (error, stackTrace) => const SizedBox.shrink(),
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              TrendingTagsPlaceholder(
                tags: ref.watch(_top15PlaceholderTagsProvider),
              ),
            ],
          ),
        );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'search.trending'.tr().toUpperCase(),
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
