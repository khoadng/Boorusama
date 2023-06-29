// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'converter.dart';
import 'parser.dart';
import 'user.dart';
import 'user_dto.dart';
import 'user_self.dart';
import 'user_self_dto.dart';

abstract class UserRepository {
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
  Future<User> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}

class UserRepositoryApi implements UserRepository {
  UserRepositoryApi(
    this._api,
    this.defaultBlacklistedTags,
  );

  final DanbooruApi _api;
  final List<String> defaultBlacklistedTags;

  @override
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  }) =>
      _api
          .getUsersByIdStringComma(
            idComma,
            1000,
            cancelToken: cancelToken,
          )
          .then(parseUserDtos)
          .then(parseUsers)
          .catchError((e) => <User>[]);

  @override
  Future<User> getUserById(int id) => _api
      .getUserById(id)
      .then((value) => Map<String, dynamic>.from(value.response.data))
      .then((e) => UserDto.fromJson(e))
      .then(userDtoToUser);

  @override
  Future<UserSelf?> getUserSelfById(int id) => _api
      .getUserById(id)
      .then((value) => Map<String, dynamic>.from(value.response.data))
      .then((e) => UserSelfDto.fromJson(e))
      .then((d) => userDtoToUserSelf(d, defaultBlacklistedTags));
}
