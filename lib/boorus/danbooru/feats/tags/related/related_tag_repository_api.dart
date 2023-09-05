// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/http/http.dart';

const _kTagLimit = 300;

class RelatedTagRepositoryApi implements RelatedTagRepository {
  const RelatedTagRepositoryApi(
    this.api,
  );

  final DanbooruApi api;

  @override
  Future<RelatedTag> getRelatedTag(
    String query, {
    TagCategory? category,
    RelatedType? order,
  }) =>
      api
          .getRelatedTag(query, category?.name, order?.name, _kTagLimit)
          .then(extractData)
          .then(RelatedTagDto.fromJson)
          .then(relatedTagDtoToRelatedTag)
          .catchError((obj) => const RelatedTag.empty());
}

RelatedTag relatedTagDtoToRelatedTag(RelatedTagDto dto) => RelatedTag(
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
