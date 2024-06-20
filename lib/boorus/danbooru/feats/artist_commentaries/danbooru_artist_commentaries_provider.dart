// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
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

final danbooruArtistCommentaryProvider =
    FutureProvider.autoDispose.family<ArtistCommentary, int>(
  (ref, postId) async {
    final config = ref.watchConfig;
    final repo = ref.watch(danbooruArtistCommentaryRepoProvider(config));
    final commentary = await repo.getCommentary(postId);

    return commentary;
  },
);
