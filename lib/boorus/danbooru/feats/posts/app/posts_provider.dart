// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

part 'posts_count_provider.dart';
part 'posts_details_provider.dart';

final danbooruPostRepoProvider = Provider<DanbooruPostRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  final booruConfig = ref.watch(currentBooruConfigProvider);

  final settingsRepo = ref.watch(settingsRepoProvider);
  final globalBlacklistedTagRepo = ref.watch(globalBlacklistedTagRepoProvider);

  return PostRepositoryApi(
    api,
    booruConfig,
    settingsRepo,
    globalBlacklistedTagRepo,
  );
});

final danbooruArtistCharacterPostRepoProvider =
    Provider<DanbooruPostRepository>((ref) {
  final postRepo = ref.watch(danbooruPostRepoProvider);

  return DanbooruArtistCharacterPostRepository(
    repository: postRepo,
    cache: LruCacher(),
  );
});
