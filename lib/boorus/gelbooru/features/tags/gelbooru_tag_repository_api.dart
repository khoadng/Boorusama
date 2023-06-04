// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/gelbooru.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import 'tag_dto.dart';

class GelbooruTagRepositoryApi implements TagRepository {
  GelbooruTagRepositoryApi(this._api);

  final GelbooruApi _api;

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) {
    return _api
        .getTags(
          null,
          null,
          'dapi',
          'tag',
          'index',
          stringComma.split(',').join(' '),
          '1',
          (page - 1).toString(),
        )
        .then(parseTags);
  }
}

List<Tag> parseTags(HttpResponse<dynamic> value) {
  final dtos = <TagDto>[];
  for (final item in value.response.data['tag']) {
    dtos.add(TagDto.fromJson(item));
  }

  return dtos.map(tagDtoToTag).toList();
}

Tag tagDtoToTag(TagDto e) {
  return Tag(
    name: e.name ?? '',
    category: intToTagCategory(e.type ?? 0),
    postCount: e.count ?? 0,
  );
}
