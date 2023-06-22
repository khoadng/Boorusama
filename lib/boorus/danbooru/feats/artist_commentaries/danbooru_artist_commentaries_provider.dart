// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'danbooru_artist_commentary_notifier.dart';
import 'danbooru_artist_commentary_repository.dart';
import 'danbooru_artist_commentary_repository_api.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider<DanbooruArtistCommentaryRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return DanbooruArtistCommentaryRepositoryApi(api, booruConfig);
  },
);

final danbooruArtistCommentariesProvider = NotifierProvider<
    DanbooruArtistCommentariesNotifier, Map<int, ArtistCommentary>>(
  DanbooruArtistCommentariesNotifier.new,
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
