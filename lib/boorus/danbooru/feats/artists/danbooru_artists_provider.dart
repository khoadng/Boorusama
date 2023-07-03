// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

final danbooruArtistRepoProvider = Provider<DanbooruArtistRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return DanbooruArtistRepositoryApi(api: api);
});

final danbooruArtistProvider = AsyncNotifierProvider.family<
    DanbooruArtistNotifier, DanbooruArtist, String>(
  DanbooruArtistNotifier.new,
);
