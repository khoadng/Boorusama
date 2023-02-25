// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'user.dart';

abstract class UserRepository {
  Future<List<UserSelf>> getUsersByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
  Future<UserSelf> getUserById(int id);
  Future<void> setUserBlacklistedTags(int id, String blacklistedTags);
}
