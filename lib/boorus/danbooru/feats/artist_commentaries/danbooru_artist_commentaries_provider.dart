// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'danbooru_artist_commentary_notifier.dart';
import 'danbooru_artist_commentary_repository.dart';
import 'danbooru_artist_commentary_repository_api.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider.family<DanbooruArtistCommentaryRepository, BooruConfig>(
  (ref, config) {
    return DanbooruArtistCommentaryRepositoryApi(
      ref.watch(danbooruClientProvider(config)),
    );
  },
);

final danbooruArtistCommentariesProvider = NotifierProvider.family<
    DanbooruArtistCommentariesNotifier,
    Map<int, ArtistCommentary>,
    BooruConfig>(
  DanbooruArtistCommentariesNotifier.new,
  dependencies: [
    danbooruArtistCommentaryRepoProvider,
  ],
);

final danbooruArtistCommentaryProvider =
    Provider.autoDispose.family<ArtistCommentary, int>(
  (ref, postId) {
    final config = ref.watchConfig;
    final commentaries = ref.watch(danbooruArtistCommentariesProvider(config));
    final commentary = commentaries[postId];

    return commentary ?? ArtistCommentary.empty();
  },
);
