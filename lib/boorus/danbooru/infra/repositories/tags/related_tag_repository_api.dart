// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

class RelatedTagRepositoryApi implements RelatedTagRepository {
  const RelatedTagRepositoryApi(Api api) : _api = api;

  final Api _api;

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
