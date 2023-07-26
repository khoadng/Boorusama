// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

final danbooruArtistRepoProvider = Provider<DanbooruArtistRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return DanbooruArtistRepositoryApi(api: api);
});

final danbooruArtistUrlRepoProvider = Provider<DanbooruArtistUrlRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);

    return DanbooruArtistUrlRepositoryApi(api: api);
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
