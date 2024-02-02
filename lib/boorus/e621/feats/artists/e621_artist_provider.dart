// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

final e621ArtistRepoProvider =
    Provider.family<E621ArtistRepository, BooruConfig>((ref, config) {
  return E621ArtistRepositoryApi(
    ref.watch(e621ClientProvider(config)),
  );
});

final e621ArtistProvider =
    FutureProvider.autoDispose.family<E621Artist, String>((ref, name) async {
  final config = ref.watchConfig;
  final repo = ref.read(e621ArtistRepoProvider(config));
  final artist = await repo.getArtist(name);
  return artist.getOrElse(() => const E621Artist.empty());
});

final e621ArtistPostsProvider = FutureProvider.autoDispose
    .family<List<E621Post>, String?>((ref, name) async {
  if (name == null) return [];
  final config = ref.watchConfig;

  final globalBlacklistedTags = ref.watch(globalBlacklistedTagsProvider);

  final repo = ref.read(e621PostRepoProvider(config));
  final posts = await repo.getPostsFromTagsOrEmpty([name], 1);

  return filterTags(
    posts.take(30).where((e) => !e.isFlash).toList(),
    {
      ...globalBlacklistedTags.map((e) => e.name),
    },
  );
});
