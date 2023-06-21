// Package imports:
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/e621/e621_api.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/e621/feats/tags/e621_tag_dto.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'e621_tag.dart';
import 'e621_tag_utils.dart';

enum E621TagSortOrder {
  date,
  count,
  name,
}

abstract interface class E621TagRepository {
  Future<List<E621Tag>> getTagsWithWildcard(
    String tag, {
    E621TagSortOrder order = E621TagSortOrder.count,
  });
}

class E621TagRepositoryApi implements E621TagRepository {
  E621TagRepositoryApi(this.api, this.booruConfig);

  final E621Api api;
  final BooruConfig booruConfig;

  @override
  Future<List<E621Tag>> getTagsWithWildcard(
    String tag, {
    E621TagSortOrder order = E621TagSortOrder.count,
  }) =>
      api
          .getTagsByNamePattern(
            booruConfig.login,
            booruConfig.apiKey,
            1,
            'true',
            appendWildcard(tag),
            mapOrderToString(order),
            20,
          )
          .then(parseDtos)
          .then(parseTags)
          .catchError((e, stackTrace) => <E621Tag>[]);
}

List<E621TagDto> parseDtos(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => E621TagDto.fromJson(item),
    );

List<E621Tag> parseTags(List<E621TagDto> dtos) =>
    dtos.map(e621TagDtoToTag).toList();

String appendWildcard(String tag) => '$tag*';
String mapOrderToString(E621TagSortOrder order) => order.name;
