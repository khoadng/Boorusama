// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'danbooru_post_version.dart';

final danbooruPostVersionsRepoProvider =
    Provider.family<DanbooruPostVersionRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruPostVersionRepository(client: client);
});

final danbooruPostVersionsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPostVersion>, int>((ref, id) async {
  final config = ref.watchConfig;
  final repo = ref.watch(danbooruPostVersionsRepoProvider(config));

  return repo.getPostVersions(id: id);
});

class DanbooruPostVersionRepository {
  final DanbooruClient client;

  DanbooruPostVersionRepository({
    required this.client,
  });

  Future<List<DanbooruPostVersion>> getPostVersions({
    required int id,
  }) =>
      client.getPostVersions(id: id).then((value) => value
          .map((e) => DanbooruPostVersion(
                id: id,
                postId: e.postId ?? 0,
                tags: e.tags ?? '',
                addedTags: e.addedTags ?? [],
                removedTags: e.removedTags ?? [],
                updaterId: e.updaterId ?? 0,
                updatedAt: e.updatedAt != null
                    ? DateTime.tryParse(e.updatedAt!) ?? DateTime.now()
                    : DateTime.now(),
                rating: e.rating ?? '',
                ratingChanged: e.ratingChanged ?? false,
                parentId: e.parentId,
                parentChanged: e.parentChanged ?? false,
                source: e.source ?? '',
                sourceChanged: e.sourceChanged ?? false,
                version: e.version ?? 0,
                obsoleteAddedTags: e.obsoleteAddedTags ?? '',
                obsoleteRemovedTags: e.obsoleteRemovedTags ?? '',
                unchangedTags: e.unchangedTags ?? '',
                updater: Creator(
                  id: e.updater?.id ?? 0,
                  name: e.updater?.name ?? '',
                  level: stringToUserLevel(e.updater?.levelString),
                ),
              ))
          .toList());
}
