// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
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
  return ref
      .watch(e621PostRepoProvider(ref.watchConfig))
      .getPostsFromTagWithBlacklist(
        tag: name,
        blacklist: ref.watch(blacklistTagsProvider(ref.watchConfig).future),
      );
});
