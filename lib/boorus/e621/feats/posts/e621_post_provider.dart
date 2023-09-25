// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';

final e621PostRepoProvider = Provider<E621PostRepository>((ref) {
  return E621PostRepositoryApi(
    ref.watch(e621ClientProvider),
    ref.watch(currentBooruConfigProvider),
    ref.watch(settingsRepoProvider),
    onFetch: (posts) => ref.read(e621FavoritesProvider.notifier).preload(posts),
  );
});

final e621PopularPostRepoProvider = Provider<E621PopularRepository>((ref) {
  return E621PopularRepositoryApi(
    ref.watch(e621ClientProvider),
    ref.watch(currentBooruConfigProvider),
    ref.watch(settingsRepoProvider),
  );
});
