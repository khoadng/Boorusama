// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';

final gelbooruArtistPostRepo =
    Provider.family<PostRepository<GelbooruPost>, BooruConfig>((ref, config) {
  return PostRepositoryCacher(
    keyBuilder: (tags, page, {limit}) => '${tags.join('-')}_${page}_$limit',
    repository: ref.watch(gelbooruPostRepoProvider(config)),
    cache: LruCacher(capacity: 100),
  );
});

final gelbooruArtistPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruPost>, String?>((ref, artistName) async {
  return ref
      .watch(gelbooruArtistPostRepo(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig)),
      );
});
