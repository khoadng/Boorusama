// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';
import 'package:boorusama/foundation/loggers/loggers.dart';

part 'posts_count_provider.dart';

final danbooruPostRepoProvider = Provider<DanbooruPostRepository>((ref) {
  return PostRepositoryApi(
    ref.watch(danbooruClientProvider),
    ref.watch(currentBooruConfigProvider),
    ref.watch(settingsRepoProvider),
    !kReleaseMode ? ref.watch(loggerProvider) : EmptyLogger(),
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
