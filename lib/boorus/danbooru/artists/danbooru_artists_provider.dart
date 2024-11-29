// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';

final danbooruArtistRepoProvider =
    Provider.family<DanbooruArtistRepository, BooruConfigAuth>((ref, config) {
  return DanbooruArtistRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruArtistUrlRepoProvider =
    Provider.family<DanbooruArtistUrlRepository, BooruConfigAuth>(
  (ref, config) {
    return DanbooruArtistUrlRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);

final danbooruArtistProvider = AsyncNotifierProvider.family<
    DanbooruArtistNotifier, DanbooruArtist, String>(
  DanbooruArtistNotifier.new,
);

final danbooruArtistUrlProvider = FutureProvider.autoDispose
    .family<List<DanbooruArtistUrl>, int>((ref, artistId) async {
  final config = ref.watchConfigAuth;
  final repo = ref.watch(danbooruArtistUrlRepoProvider(config));

  return repo.getArtistUrls(artistId);
});
