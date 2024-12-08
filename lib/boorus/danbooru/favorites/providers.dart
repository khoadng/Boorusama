// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'favorite_post_repository.dart';
import 'favorite_post_repository_api.dart';

final danbooruFavoriteRepoProvider =
    Provider.family<FavoritePostRepository, BooruConfigAuth>((ref, config) {
  return FavoritePostRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});
