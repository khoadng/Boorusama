// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'converter.dart';
import 'parser.dart';
import 'user.dart';
import 'user_self.dart';

abstract class UserRepository {
  Future<List<User>> getUsersByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  });
  Future<User> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}

class UserRepositoryApi implements UserRepository {
  UserRepositoryApi(
    this.client,
    this.defaultBlacklistedTags,
  );

  final DanbooruClient client;
  final List<String> defaultBlacklistedTags;

  @override
  Future<List<User>> getUsersByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  }) =>
      client
          .getUsersByIds(
            ids: ids,
            limit: 1000,
            cancelToken: cancelToken,
          )
          .then(parseUsers)
          .catchError((e) => <User>[]);

  @override
  Future<User> getUserById(int id) =>
      client.getUserById(id: id).then(userDtoToUser);

  @override
  Future<UserSelf?> getUserSelfById(int id) => client
      .getUserSelfById(id: id)
      .then((d) => userDtoToUserSelf(d, defaultBlacklistedTags));
}
