// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/i_user_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_dto.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/i_api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<User> parseUser(HttpResponse<dynamic> value) => parse(
      value: value,
      converter: (item) => UserDto.fromJson(item),
    ).map(userDtoToUser).toList();

class UserRepository implements IUserRepository {
  UserRepository(this._api, this._accountRepository);

  final IAccountRepository _accountRepository;
  final IApi _api;

  @override
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  }) async {
    try {
      return _api
          .getUsersByIdStringComma(
            idComma,
            1000,
            cancelToken: cancelToken,
          )
          .then(parseUser);
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception("Failed to get users for $idComma");
      }
    }
  }

  @override
  Future<User> getUserById(int id) => _accountRepository
      .get()
      .then(
        (account) => _api.getUserById(
          account.username,
          account.apiKey,
          id,
        ),
      )
      .then((value) => Map<String, dynamic>.from(value.response.data))
      .then((e) => UserDto.fromJson(e))
      .then(userDtoToUser)
      .catchError(
          (Object obj) => throw Exception("Failed to get user info for $id"));

  @override
  Future<void> setUserBlacklistedTags(int id, String blacklistedTags) =>
      _accountRepository
          .get()
          .then(
            (account) => _api.setBlacklistedTags(
              account.username,
              account.apiKey,
              id,
              blacklistedTags,
            ),
          )
          .catchError((Object obj) =>
              throw Exception("Failed to save $blacklistedTags for $id"));
}
