// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/caching/caching.dart';

final gelbooruV2ArtistPostRepo =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfig>((ref, config) {
  return PostRepositoryCacher(
    keyBuilder: (tags, page, {limit}) =>
        '${tags.split(' ').join('-')}_${page}_$limit',
    repository: ref.watch(gelbooruV2PostRepoProvider(config)),
    cache: LruCacher(capacity: 100),
  );
});

final gelbooruV2ArtistPostsProvider = FutureProvider.autoDispose
    .family<List<GelbooruV2Post>, String?>((ref, artistName) async {
  return ref
      .watch(gelbooruV2ArtistPostRepo(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig).future),
      );
});
