// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/favorite_groups/favorite_group_repository.dart';
import 'package:boorusama/core/configs.dart';
import '../danbooru_provider.dart';
import 'favorite_group_repository_api.dart';

final danbooruFavoriteGroupRepoProvider =
    Provider.family<FavoriteGroupRepository, BooruConfigAuth>((ref, config) {
  return FavoriteGroupRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});
