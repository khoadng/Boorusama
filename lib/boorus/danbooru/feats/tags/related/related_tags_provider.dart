// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

const _kTagLimit = 300;

final danbooruRelatedTagRepProvider =
    Provider.family<RelatedTagRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return RelatedTagRepositoryBuilder(
    fetch: (query, {category, order}) => client
        .getRelatedTag(
          query: query,
          category: switch (category) {
            TagCategory.artist => danbooru.TagCategory.artist,
            TagCategory.charater => danbooru.TagCategory.character,
            TagCategory.general => danbooru.TagCategory.general,
            TagCategory.copyright => danbooru.TagCategory.copyright,
            TagCategory.meta => danbooru.TagCategory.meta,
            TagCategory.invalid_ => null,
            null => null,
          },
          order: switch (order) {
            RelatedType.cosine => danbooru.RelatedType.cosine,
            RelatedType.jaccard => danbooru.RelatedType.jaccard,
            RelatedType.overlap => danbooru.RelatedType.overlap,
            RelatedType.frequency => danbooru.RelatedType.frequency,
            null => null,
          },
          limit: _kTagLimit,
        )
        .then(relatedTagDtoToRelatedTag)
        .catchError((obj) => const RelatedTag.empty()),
  );
});

final danbooruRelatedTagProvider =
    FutureProvider.autoDispose.family<RelatedTag, String>(
  (ref, tag) {
    if (tag.isEmpty) return const RelatedTag.empty();

    final repo = ref.watch(danbooruRelatedTagRepProvider(ref.watchConfig));

    return repo.getRelatedTag(tag);
  },
);

final danbooruRelatedTagCosineSimilarityProvider =
    FutureProvider.autoDispose.family<RelatedTag, String>(
  (ref, tag) async {
    final relatedTag = await ref.watch(danbooruRelatedTagProvider(tag).future);

    return relatedTag.copyWith(
      tags: relatedTag.tags
          .sorted((a, b) => b.cosineSimilarity.compareTo(a.cosineSimilarity)),
    );
  },
);

RelatedTag relatedTagDtoToRelatedTag(danbooru.RelatedTagDto dto) => RelatedTag(
      query: dto.query ?? '',
      tags: dto.relatedTags != null
          ? dto.relatedTags!
              .map((e) => RelatedTagItem(
                    tag: e.tag?.name ?? '',
                    category: intToTagCategory(e.tag?.category ?? 0),
                    jaccardSimilarity: e.jaccardSimilarity ?? 0.0,
                    cosineSimilarity: e.cosineSimilarity ?? 0.0,
                    overlapCoefficient: e.overlapCoefficient ?? 0.0,
                    frequency: e.frequency ?? 0,
                    postCount: e.tag?.postCount ?? 0,
                  ))
              .toList()
          : [],
    );
