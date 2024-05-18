// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_artists.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

final danbooruArtistRepoProvider =
    Provider.family<DanbooruArtistRepository, BooruConfig>((ref, config) {
  return DanbooruArtistRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

final danbooruArtistUrlRepoProvider =
    Provider.family<DanbooruArtistUrlRepository, BooruConfig>(
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
  final config = ref.watchConfig;
  final repo = ref.watch(danbooruArtistUrlRepoProvider(config));

  return repo.getArtistUrls(artistId);
});

final artistOrderProvider =
    StateProvider.autoDispose<ArtistOrder?>((ref) => null);

final searchedArtistNameProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final searchedArtistUrlProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final danbooruArtistsProvider = StateNotifierProvider.autoDispose<
    DanbooruArtistsNotifier, PagedState<int, DanbooruArtist>>((ref) {
  final order = ref.watch(artistOrderProvider);
  final name = ref.watch(searchedArtistNameProvider);
  final url = ref.watch(searchedArtistUrlProvider);
  final repo = ref
      .watch(danbooruArtistRepoProvider(ref.watch(currentBooruConfigProvider)));

  return DanbooruArtistsNotifier(
    load: (page, limit) => repo.getArtists(
      name: name,
      url: url,
      order: order,
      page: page,
      isDeleted: false,
      hasTag: true,
      includeTag: true,
    ),
  );
});
