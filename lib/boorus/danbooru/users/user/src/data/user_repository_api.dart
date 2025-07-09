// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../types/user.dart';
import '../types/user_repository.dart';
import 'converter.dart';

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
  }) => client
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
