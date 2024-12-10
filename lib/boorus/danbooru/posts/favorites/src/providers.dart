// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config.dart';
import '../../../danbooru_provider.dart';
import 'favorite_post_repository.dart';
import 'favorite_post_repository_api.dart';

final danbooruFavoriteRepoProvider =
    Provider.family<FavoritePostRepository, BooruConfigAuth>((ref, config) {
  return FavoritePostRepositoryApi(
    ref.watch(danbooruClientProvider(config)),
  );
});
