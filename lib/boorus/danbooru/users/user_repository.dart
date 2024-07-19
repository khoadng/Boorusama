// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'converter.dart';
import 'parser.dart';
import 'user.dart';
import 'user_self.dart';

abstract class UserRepository {
  Future<List<DanbooruUser>> getUsersByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  });
  Future<DanbooruUser> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}

class UserRepositoryApi implements UserRepository {
  UserRepositoryApi(
    this.client,
    this.defaultBlacklistedTags,
  );

  final DanbooruClient client;
  final Set<String> defaultBlacklistedTags;

  @override
  Future<List<DanbooruUser>> getUsersByIds(
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
          .catchError((e) => <DanbooruUser>[]);

  @override
  Future<DanbooruUser> getUserById(int id) =>
      client.getUserById(id: id).then(userDtoToUser);

  @override
  Future<UserSelf?> getUserSelfById(int id) => client
      .getUserSelfById(id: id)
      .then((d) => userDtoToUserSelf(d, defaultBlacklistedTags));
}
