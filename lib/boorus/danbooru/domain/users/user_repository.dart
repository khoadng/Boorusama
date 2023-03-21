// Package imports:
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:dio/dio.dart';

abstract class UserRepository {
  Future<List<User>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
  Future<User> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}
