// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/functional.dart';

final danbooruRelatedTagRepProvider =
    Provider.family<RelatedTagRepository, BooruConfig>((ref, config) {
  return RelatedTagRepositoryApi(ref.watch(danbooruClientProvider(config)));
});

final danbooruRelatedTagsProvider = NotifierProvider.family<RelatedTagsNotifier,
    IMap<String, RelatedTag>, BooruConfig>(
  RelatedTagsNotifier.new,
);

final danbooruRelatedTagProvider =
    Provider.autoDispose.family<RelatedTag?, String>(
  (ref, tag) {
    final config = ref.watchConfig;
    return ref.watch(danbooruRelatedTagsProvider(config))[tag];
  },
);

final danbooruRelatedTagCosineSimilarityProvider =
    Provider.autoDispose.family<RelatedTag?, String>(
  (ref, tag) {
    final relatedTag = ref.watch(danbooruRelatedTagProvider(tag));

    if (relatedTag == null) return null;

    return relatedTag.copyWith(
      tags: relatedTag.tags
          .sorted((a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity)),
    );
  },
);
