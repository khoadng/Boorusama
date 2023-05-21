// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/notes.dart';
import 'package:boorusama/boorus/danbooru/application/pools.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/count/post_count_repository_api.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_artist_character_post_repository.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/blacklists.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/provider.dart';
import 'post_details_artist_notifier.dart';
import 'post_details_character_notifier.dart';
import 'post_details_children_notifier.dart';
import 'post_details_pools_notifier.dart';
import 'post_details_tags_notifier.dart';

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

final postShareProvider =
    NotifierProvider.family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
