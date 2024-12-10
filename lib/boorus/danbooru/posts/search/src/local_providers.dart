// Dart imports:
import 'dart:math';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import '../../../tags/tag/providers.dart';
import '../../../tags/trending/providers.dart';
import '../../../tags/trending/trending.dart';
import 'trending_tag.dart';

final _kTrendingTagCount = 15;

final top15TrendingTagsProvider = FutureProvider.autoDispose
    .family<List<TrendingTag>, BooruConfigAuth>((ref, config) async {
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

final top15PlaceholderTagsProvider = Provider<List<TrendingTag>>((ref) {
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
