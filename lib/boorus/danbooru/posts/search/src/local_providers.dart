// Dart imports:
import 'dart:math';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/tags/categories/types.dart';
import '../../../../../core/tags/tag/types.dart';
import '../../../tags/trending/providers.dart';

const _kTrendingTagCount = 15;

final top15TrendingTagsProvider = FutureProvider.autoDispose
    .family<List<Tag>, BooruConfigFilter>((ref, config) async {
      final tags = await ref.watch(trendingTagsProvider(config).future);

      return tags.take(_kTrendingTagCount).toList(growable: false);
    });

final top15PlaceholderTagsProvider = Provider<List<Tag>>((ref) {
  final tags = <Tag>[];
  final rnd = Random();
  const minChar = 6;
  const maxChar = 20;

  for (var i = 0; i < _kTrendingTagCount; i++) {
    final sb = StringBuffer();
    final length = minChar + rnd.nextInt(maxChar - minChar);
    for (var j = 0; j < length; j++) {
      sb.write('a');
    }

    tags.add(
      Tag(
        name: sb.toString(),
        category: TagCategory.unknown(),
        postCount: rnd.nextInt(1000),
      ),
    );
  }

  return tags;
});
