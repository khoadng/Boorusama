// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/blacklists/global_blacklisted_tags_provider.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/moebooru.dart';
import 'moebooru_post_repository_api.dart';

final moebooruPostRepoProvider = Provider<MoebooruPostRepositoryApi>(
  (ref) {
    final api = ref.watch(moebooruClientProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    final settingsRepository = ref.watch(settingsRepoProvider);

    return MoebooruPostRepositoryApi(
      api,
      booruConfig,
      settingsRepository,
    );
  },
  dependencies: [
    moebooruClientProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
    settingsRepoProvider,
  ],
);

final moebooruPopularRepoProvider = Provider<MoebooruPopularRepository>(
  (ref) {
    final api = ref.watch(moebooruClientProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return MoebooruPopularRepositoryApi(
      api,
      booruConfig,
    );
  },
  dependencies: [
    moebooruClientProvider,
    globalBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);

final moebooruPostDetailsChildrenProvider =
    FutureProvider.family.autoDispose<List<Post>?, Post>(
  (ref, post) async {
    if (!post.hasParentOrChildren) return null;

    final repo = ref.watch(moebooruPostRepoProvider);

    final query =
        post.parentId != null ? 'parent:${post.parentId}' : 'parent:${post.id}';

    final posts = await repo.getPostsFromTags(query, 1).run();

    return posts.fold(
      (l) => null,
      (r) => r,
    );
  },
  dependencies: [
    moebooruPostRepoProvider,
  ],
);
