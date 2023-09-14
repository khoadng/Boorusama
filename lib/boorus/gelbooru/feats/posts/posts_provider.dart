// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/gelbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final gelbooruPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(gelbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final settingsRepository = ref.watch(settingsRepoProvider);

    return GelbooruPostRepositoryApi(
      api: api,
      booruConfig: booruConfig,
      settingsRepository: settingsRepository,
    );
  },
);

final gelbooruV2dot0PostRepoProvider =
    Provider<GelbooruV0Dot2PostRepositoryApi>(
  (ref) {
    final api = ref.watch(gelbooruV2dot0ApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final settingsRepository = ref.watch(settingsRepoProvider);

    return GelbooruV0Dot2PostRepositoryApi(
      api: api,
      baseUrl: booruConfig.url,
      booruConfig: booruConfig,
      settingsRepository: settingsRepository,
    );
  },
);

final rule34xxxPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(rule34xxxApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final settingsRepository = ref.watch(settingsRepoProvider);

    return Rule34xxxPostRepositoryApi(
      api: api,
      booruConfig: booruConfig,
      settingsRepository: settingsRepository,
    );
  },
);

final gelbooruArtistCharacterPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(gelbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final settingsRepository = ref.watch(settingsRepoProvider);

    return PostRepositoryCacher(
      repository: GelbooruPostRepositoryApi(
        api: api,
        booruConfig: booruConfig,
        settingsRepository: settingsRepository,
      ),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);

final gelbooruPostCountRepoProvider = Provider<PostCountRepository>((ref) {
  return GelbooruPostCountRepositoryApi(
    api: ref.watch(gelbooruApiProvider),
    booruConfig: ref.watch(currentBooruConfigProvider),
  );
});
