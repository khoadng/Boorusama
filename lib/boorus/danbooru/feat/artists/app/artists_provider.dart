// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feat/artists/artists.dart';

final danbooruArtistRepoProvider = Provider<ArtistRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return ArtistRepositoryApi(api: api);
});

final danbooruArtistProvider =
    AsyncNotifierProvider.family<ArtistNotifier, Artist, String>(
  ArtistNotifier.new,
);
