// Package imports:
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'user.dart';

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

class CreatorRepositoryFromUserRepo implements CreatorRepository {
  CreatorRepositoryFromUserRepo(
    this.repo,
    this.box,
  );

  final UserRepository repo;
  final Box box;

  @override
  Future<List<Creator>> getCreatorsByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  }) async {
    final now = DateTime.now();
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    final ids = idComma.split(',').toSet();

    // Identify IDs not in cache
    final idsNotInCached = ids.where((e) => !box.containsKey(e)).toList();

    // Fetch creators from cache
    final creatorInCached = ids
        .where((e) => box.containsKey(e))
        .map((e) => Creator.fromJson(box.get(e)['creator']))
        .toList();

    List<Creator> creators = [];

    // Only fetch creators from API when there are uncached IDs
    if (idsNotInCached.isNotEmpty) {
      try {
        creators = await repo
            .getUsersByIds(
              idsNotInCached.map((e) => int.tryParse(e)).nonNulls.toList(),
              cancelToken: cancelToken,
            )
            .then((value) => value.map(Creator.fromUser).toList());
      } catch (e) {
        // handle the exception
      }

      for (final e in creators) {
        if (!box.containsKey(e.id.toString()) ||
            DateTime.parse(box.get(e.id.toString())['time'])
                .isBefore(twoDaysAgo)) {
          // Update cache with new creators
          box.put(e.id.toString(), {
            'time': now.toIso8601String(),
            'creator': e.toJson(),
          });
        }
      }
    }

    return [...creators, ...creatorInCached];
  }
}
