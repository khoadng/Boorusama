// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/api/api.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tags.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/core/infra/http_parser.dart';

List<Tag> parseTag(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => TagDto.fromJson(item),
    ).map(tagDtoToTag).toList();

class TagRepositoryApi implements TagRepository {
  TagRepositoryApi(
    this._api,
    this._accountRepository,
  );

  final Api _api;
  final AccountRepository _accountRepository;

  @override
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page) =>
      _accountRepository
          .get()
          .then(
            (account) => _api.getTagsByNamePattern(
              account.username,
              account.apiKey,
              page,
              'yes',
              '$stringPattern*',
              'count',
              30,
            ),
          )
          .then(parseTag)
          .catchError((Object obj) =>
              throw Exception('Failed to get tags for $stringPattern'));

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _accountRepository
          .get()
          .then((account) => _api.getTagsByNameComma(
                account.username,
                account.apiKey,
                page,
                'yes',
                stringComma,
                'count',
                1000,
                cancelToken: cancelToken,
              ))
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
      category: TagCategory.values[d.category ?? 0],
      postCount:
          d.postCount != null ? PostCountType(d.postCount!) : PostCountType(0),
    );
