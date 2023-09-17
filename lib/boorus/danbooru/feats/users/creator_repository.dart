// Package imports:
import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

// Project imports:
import 'creator.dart';
import 'user_repository.dart';

abstract interface class CreatorRepository {
  Future<List<Creator>> getCreatorsByIdStringComma(
    String idComma, {
    CancelToken? cancelToken,
  });
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

    final ids = idComma.split(',');

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
              idsNotInCached
                  .map((e) => int.tryParse(e))
                  .whereNotNull()
                  .toList(),
              cancelToken: cancelToken,
            )
            .then((value) => value.map(Creator.fromUser).toList());
      } catch (e) {
        // handle the exception
      }

      for (var e in creators) {
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
