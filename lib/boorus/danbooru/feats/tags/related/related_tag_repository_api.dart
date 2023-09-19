// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;

const _kTagLimit = 300;

class RelatedTagRepositoryApi implements RelatedTagRepository {
  const RelatedTagRepositoryApi(
    this.client,
  );

  final DanbooruClient client;

  @override
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
  }) =>
      client
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
          .catchError((obj) => const RelatedTag.empty());
}

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
