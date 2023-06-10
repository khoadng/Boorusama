// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/foundation/http/http.dart';

class RelatedTagRepositoryApi implements RelatedTagRepository {
  const RelatedTagRepositoryApi(DanbooruApi api) : _api = api;

  final DanbooruApi _api;

  @override
  Future<RelatedTag> getRelatedTag(String query) => _api
          .getRelatedTag(query)
          .then(extractData)
          .then(RelatedTagDto.fromJson)
          .then(relatedTagDtoToRelatedTag)
          .catchError((obj) {
        throw Exception('Failed to get related tags for $query\n\n$obj');
      });
}

RelatedTag relatedTagDtoToRelatedTag(RelatedTagDto dto) => RelatedTag(
      query: dto.query,
      tags: dto.tags
          .map((e) => RelatedTagItem(
                tag: e.first as String,
                category: intToTagCategory(e[1] as int),
              ))
          .toList(),
    );
