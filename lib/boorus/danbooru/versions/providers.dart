// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/versions/danbooru_post_version_repository.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'danbooru_post_version.dart';

final danbooruPostVersionsRepoProvider =
    Provider.family<DanbooruPostVersionRepository, BooruConfigAuth>(
        (ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  return DanbooruPostVersionRepository(client: client);
});

final danbooruPostVersionsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPostVersion>, int>((ref, id) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(danbooruPostVersionsRepoProvider(config));

  return repo.getPostVersions(id: id);
});
