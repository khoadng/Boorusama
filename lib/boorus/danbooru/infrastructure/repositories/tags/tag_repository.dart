// Package imports:
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/i_tag_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/tags/tag.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/accounts/account_repository.dart';

final tagProvider = Provider<ITagRepository>(
    (ref) => TagRepository(ref.watch(apiProvider), ref.watch(accountProvider)));

class TagRepository implements ITagRepository {
  final IApi _api;
  final IAccountRepository _accountRepository;

  TagRepository(this._api, this._accountRepository);

  @override
  Future<List<Tag>> getTagsByNamePattern(String stringPattern, int page) async {
    final account = await _accountRepository.get();

    return _api
        .getTagsByNamePattern(account.username, account.apiKey, page, "yes",
            stringPattern + "*", "count", 30)
        .then((value) {
      var tags = <Tag>[];
      for (var item in value.response.data) {
        try {
          tags.add(Tag.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
      return tags;
    }).catchError((Object obj) {
      throw Exception("Failed to get tags for $stringPattern");
    });
  }

  @override
  Future<List<Tag>> getTagsByNameComma(
    String stringComma,
    int page, {
    CancelToken? cancelToken,
  }) async {
    final account = await _accountRepository.get();

    try {
      final value = await _api.getTagsByNameComma(
        account.username,
        account.apiKey,
        page,
        "yes",
        stringComma,
        "count",
        1000,
        cancelToken: cancelToken,
      );
      var tags = <Tag>[];
      for (var item in value.response.data) {
        try {
          tags.add(Tag.fromJson(item));
        } catch (e) {
          print("Cant parse $item[id]");
        }
      }
      return tags;
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception("Failed to get posts for $stringComma");
      }
    }
  }
}
