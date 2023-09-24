// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruPostRepoProvider = Provider<GelbooruPostRepositoryApi>(
  (ref) {
    return GelbooruPostRepositoryApi(
      client: ref.watch(gelbooruClientProvider),
      booruConfig: ref.watch(currentBooruConfigProvider),
      settingsRepository: ref.watch(settingsRepoProvider),
    );
  },
);

final gelbooruArtistCharacterPostRepoProvider = Provider<PostRepository>(
  (ref) {
    return PostRepositoryCacher(
      repository: GelbooruPostRepositoryApi(
        client: ref.watch(gelbooruClientProvider),
        booruConfig: ref.watch(currentBooruConfigProvider),
        settingsRepository: ref.watch(settingsRepoProvider),
      ),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);
