// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'artist_url.dart';
import 'artist_url_repository.dart';

final danbooruArtistUrlRepoProvider =
    Provider.family<DanbooruArtistUrlRepository, BooruConfigAuth>(
  (ref, config) {
    return DanbooruArtistUrlRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);

final danbooruArtistUrlProvider = FutureProvider.autoDispose
    .family<List<DanbooruArtistUrl>, int>((ref, artistId) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(danbooruArtistUrlRepoProvider(config));

  return repo.getArtistUrls(artistId);
});
