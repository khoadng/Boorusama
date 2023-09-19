// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

final danbooruArtistRepoProvider = Provider<DanbooruArtistRepository>((ref) {
  return DanbooruArtistRepositoryApi(
    client: ref.watch(danbooruClientProvider),
  );
});

final danbooruArtistUrlRepoProvider = Provider<DanbooruArtistUrlRepository>(
  (ref) {
    return DanbooruArtistUrlRepositoryApi(
      client: ref.watch(danbooruClientProvider),
    );
  },
);

final danbooruArtistProvider = AsyncNotifierProvider.family<
    DanbooruArtistNotifier, DanbooruArtist, String>(
  DanbooruArtistNotifier.new,
);

final danbooruArtistUrlProvider =
    FutureProvider.family<List<DanbooruArtistUrl>, int>((ref, artistId) async {
  final repo = ref.watch(danbooruArtistUrlRepoProvider);

  return repo.getArtistUrls(artistId);
});
