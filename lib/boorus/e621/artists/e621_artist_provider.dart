// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/configs/ref.dart';
import '../e621.dart';
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
