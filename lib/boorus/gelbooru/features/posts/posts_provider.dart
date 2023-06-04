// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/boorus/gelbooru/infra/posts/gelbooru_post_repository_api.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/infra/posts/post_repository_cacher.dart';
import 'package:boorusama/core/provider.dart';

final gelbooruPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(gelbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final settingsRepository = ref.watch(settingsRepoProvider);

    return GelbooruPostRepositoryApi(
      api: api,
      booruConfig: booruConfig,
      blacklistedTagRepository: blacklistedTagRepository,
      settingsRepository: settingsRepository,
    );
  },
);

final gelbooruArtistCharacterPostRepoProvider = Provider<PostRepository>(
  (ref) {
    final api = ref.watch(gelbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);
    final blacklistedTagRepository =
        ref.watch(globalBlacklistedTagRepoProvider);
    final settingsRepository = ref.watch(settingsRepoProvider);

    return PostRepositoryCacher(
      repository: GelbooruPostRepositoryApi(
        api: api,
        booruConfig: booruConfig,
        blacklistedTagRepository: blacklistedTagRepository,
        settingsRepository: settingsRepository,
      ),
      cache: LruCacher<String, List<Post>>(capacity: 100),
    );
  },
);
