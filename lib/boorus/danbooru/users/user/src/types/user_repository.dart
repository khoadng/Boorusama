// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../../posts/favorites/favorite.dart';
import 'user.dart';

abstract class UserRepository {
  Future<List<DanbooruUser>> getUsersByIds(
    List<int> ids, {
    CancelToken? cancelToken,
  });
  Future<DanbooruUser> getUserById(int id);
  Future<UserSelf?> getUserSelfById(int id);
}

Future<List<DanbooruUser>> Function(List<Favorite> favs) createUserWith(
  UserRepository userRepository,
) => (favs) async {
  if (favs.isEmpty) {
    return [];
  }

  return userRepository.getUsersByIds(
    favs.map((e) => e.userId).toList(),
  );
};
