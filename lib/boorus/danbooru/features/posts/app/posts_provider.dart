// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/features/notes/notes.dart';
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/features/posts/data.dart';
import 'package:boorusama/core/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/caching/lru_cacher.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/provider.dart';
import '../models/danbooru_post.dart';
import '../models/danbooru_post_repository.dart';
import '../models/post_count_repository.dart';
import 'post_count_notifier.dart';
import 'post_count_state.dart';
import 'post_details_artist_notifier.dart';
import 'post_details_character_notifier.dart';
import 'post_details_children_notifier.dart';
import 'post_details_note_notifier.dart';
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
