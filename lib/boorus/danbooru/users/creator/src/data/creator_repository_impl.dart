// Package imports:
import 'package:dio/dio.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../user/user.dart';
import '../types/creator.dart';
import '../types/creator_repository.dart';

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

    var creators = <Creator>[];

    // Only fetch creators from API when there are uncached IDs
    if (idsNotInCached.isNotEmpty) {
      try {
        creators = await repo
            .getUsersByIds(
              idsNotInCached.map((e) => int.tryParse(e)).nonNulls.toList(),
              cancelToken: cancelToken,
            )
            .then(
              (value) => value
                  .map(
                    (u) => Creator(
                      id: u.id,
                      name: u.name,
                      level: u.level,
                    ),
                  )
                  .toList(),
            );
      } catch (e) {
        // handle the exception
      }

      for (final e in creators) {
        if (!box.containsKey(e.id.toString()) ||
            DateTime.parse(
              box.get(e.id.toString())['time'],
            ).isBefore(twoDaysAgo)) {
          // Update cache with new creators
          await box.put(e.id.toString(), {
            'time': now.toIso8601String(),
            'creator': e.toJson(),
          });
        }
      }
    }

    return [...creators, ...creatorInCached];
  }
}
