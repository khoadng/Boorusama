// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/infra/http_parser.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'tag_dto.dart';

List<Tag> parseTag(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => TagDto.fromJson(item),
    ).map(tagDtoToTag).toList();

class TagRepositoryApi implements TagRepository {
  TagRepositoryApi(
    this._api,
    this.booruConfig,
  );

  final DanbooruApi _api;
  final BooruConfig booruConfig;

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getTagsByNameComma(
            booruConfig.login,
            booruConfig.apiKey,
            page,
            'yes',
            stringComma,
            'count',
            1000,
            cancelToken: cancelToken,
          )
          .then(parseTag);
    } on DioError catch (e, stackTrace) {
      if (e.type == DioErrorType.cancel) {
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
