// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../../../../../../core/users/types.dart';
import '../types/user.dart';
import 'converter.dart';

class DanbooruUserRepository implements UserRepository<DanbooruUser> {
  DanbooruUserRepository(
    this.client,
    this.defaultBlacklistedTags,
  );

  final DanbooruClient client;
  final Set<String> defaultBlacklistedTags;

  @override
  UserListFetcher<DanbooruUser> get getUsersByIds =>
      (
        ids, {
        cancelToken,
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

  Future<UserSelf?> getUserSelfById(int id) => client
      .getUserSelfById(id: id)
      .then((d) => userDtoToUserSelf(d, defaultBlacklistedTags));

  @override
  UserByNameFetcher<DanbooruUser>? get getUserByName => null;
}
