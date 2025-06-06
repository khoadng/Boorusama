// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/blacklists/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../../../core/posts/post/providers.dart';
import '../e621.dart';
import '../posts/posts.dart';
import 'artists.dart';

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
    .family<List<E621Post>, (BooruConfigFilter, BooruConfigSearch, String?)>(
        (ref, params) async {
  final (filter, search, name) = params;

  return ref.watch(e621PostRepoProvider(search)).getPostsFromTagWithBlacklist(
        tag: name,
        blacklist: ref.watch(blacklistTagsProvider(filter).future),
      );
});
