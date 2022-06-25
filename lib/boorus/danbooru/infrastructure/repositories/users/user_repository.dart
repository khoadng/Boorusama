// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/apis/api.dart';
import 'package:boorusama/core/infrastructure/http_parser.dart';

List<User> parseUser(
  HttpResponse<dynamic> value,
  List<String> defaultBlacklistedTags,
) =>
    parse(
      value: value,
      converter: (item) => UserDto.fromJson(item),
    ).map((u) => userDtoToUser(u, defaultBlacklistedTags)).toList();

class UserRepository implements IUserRepository {
  UserRepository(
    this._api,
    this._accountRepository,
    this.defaultBlacklistedTags,
  );

  final IAccountRepository _accountRepository;
  final Api _api;
  final List<String> defaultBlacklistedTags;

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
          .then((u) => parseUser(u, defaultBlacklistedTags));
    } on DioError catch (e) {
      if (e.type == DioErrorType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        throw Exception('Failed to get users for $idComma');
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
      .then((d) => userDtoToUser(d, defaultBlacklistedTags))
      .catchError(
          (Object obj) => throw Exception('Failed to get user info for $id'));

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
              throw Exception('Failed to save $blacklistedTags for $id'));
}
