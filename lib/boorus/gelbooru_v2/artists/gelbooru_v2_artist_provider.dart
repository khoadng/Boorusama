// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru_v2/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/foundation/caching.dart';

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
