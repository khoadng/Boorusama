// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/foundation/caching.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/posts/post/providers.dart';
import '../posts/posts.dart';

final gelbooruV2ArtistPostRepo =
    Provider.family<PostRepository<GelbooruV2Post>, BooruConfigSearch>(
        (ref, config) {
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
      .watch(gelbooruV2ArtistPostRepo(ref.watchConfigSearch))
      .getPostsFromTagWithBlacklist(
        tag: artistName,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfigAuth).future),
      );
});
