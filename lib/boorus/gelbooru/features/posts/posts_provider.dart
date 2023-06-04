// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/features/posts/posts.dart';
import 'package:boorusama/boorus/gelbooru/gelbooru_provider.dart';
import 'package:boorusama/core/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/boorus/providers.dart';
import 'package:boorusama/core/posts/post_repository_cacher.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

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
