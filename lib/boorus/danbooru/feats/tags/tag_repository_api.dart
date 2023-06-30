// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/http/http.dart';
import 'tag_dto.dart';

List<Tag> parseTag(HttpResponse<dynamic> value) => parseResponse(
      value: value,
      converter: (item) => TagDto.fromJson(item),
    ).map(tagDtoToTag).toList();

class TagRepositoryApi implements TagRepository {
  TagRepositoryApi(
    this._api,
  );

  final DanbooruApi _api;

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getTagsByNameComma(
            page,
            'yes',
            stringComma,
            'count',
            1000,
            cancelToken: cancelToken,
          )
          .then(parseTag);
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get posts for $stringComma'),
          stackTrace,
        );
      }
    }
  }
}

Tag tagDtoToTag(TagDto d) => Tag(
      name: d.name ?? '',
      category: intToTagCategory(d.category ?? 0),
      postCount: d.postCount ?? 0,
    );
