// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider<ArtistCommentaryRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return ArtistCommentaryRepositoryApi(api, booruConfig);
  },
);

final danbooruArtistCommentariesProvider =
    NotifierProvider<ArtistCommentariesNotifier, Map<int, ArtistCommentary>>(
  ArtistCommentariesNotifier.new,
  dependencies: [
    danbooruArtistCommentaryRepoProvider,
  ],
);

final danbooruArtistCommentaryProvider = Provider.family<ArtistCommentary, int>(
  (ref, postId) {
    final commentaries = ref.watch(danbooruArtistCommentariesProvider);
    final commentary = commentaries[postId];

    return commentary ?? ArtistCommentary.empty();
  },
);
