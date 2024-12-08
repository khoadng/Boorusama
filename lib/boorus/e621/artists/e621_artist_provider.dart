// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/posts.dart';
import 'package:boorusama/foundation/functional.dart';

final e621ArtistRepoProvider =
    Provider.family<E621ArtistRepository, BooruConfigAuth>((ref, config) {
  return E621ArtistRepositoryApi(
    ref.watch(e621ClientProvider(config)),
  );
});

final e621ArtistProvider =
    FutureProvider.autoDispose.family<E621Artist, String>((ref, name) async {
  final config = ref.watchConfigAuth;
  final repo = ref.read(e621ArtistRepoProvider(config));
  final artist = await repo.getArtist(name);
  return artist.getOrElse(() => const E621Artist.empty());
});

final e621ArtistPostsProvider = FutureProvider.autoDispose
    .family<List<E621Post>, String?>((ref, name) async {
  return ref
      .watch(e621PostRepoProvider(ref.watchConfigSearch))
      .getPostsFromTagWithBlacklist(
        tag: name,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfigAuth).future),
      );
});
