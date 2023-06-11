// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:xml/xml.dart';

// Project imports:
import 'package:boorusama/api/gelbooru/gelbooru_api.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
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
  final contentType = value.response.headers['content-type']?.firstOrNull;

  if (contentType == null) return [];

  if (contentType.contains('text/xml') ||
      contentType.contains('application/xml')) {
    var xmlDocument = XmlDocument.parse(value.data);
    var tags = xmlDocument.findAllElements('tag');
    for (final item in tags) {
      dtos.add(TagDto.fromXml(item));
    }
  } else {
    final data = value.data['tag'];
    if (data == null) return [];

    for (final item in data) {
      dtos.add(TagDto.fromJson(item));
    }
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
