// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/e621/e621.dart';
import 'package:boorusama/boorus/e621/feats/artists/artists.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

final e621ArtistRepoProvider = Provider<E621ArtistRepository>((ref) {
  return E621ArtistRepositoryApi(
    ref.watch(e621ClientProvider),
  );
});

final e621ArtistProvider =
    FutureProvider.family<E621Artist, String>((ref, name) async {
  final repo = ref.read(e621ArtistRepoProvider);
  final artist = await repo.getArtist(name);
  return artist.getOrElse(() => const E621Artist.empty());
});

final e621ArtistPostsProvider =
    FutureProvider.family<List<E621Post>, String?>((ref, name) async {
  if (name == null) return [];

  final repo = ref.read(e621PostRepoProvider);
  final posts = await repo.getPosts(name, 1).run();
  return posts.getOrElse((l) => []);
});
