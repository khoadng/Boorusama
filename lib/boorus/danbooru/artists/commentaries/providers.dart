// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/configs.dart';
import 'artist_commentary_repository.dart';
import 'artist_commentary_repository_api.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider.family<DanbooruArtistCommentaryRepository, BooruConfigAuth>(
  (ref, config) {
    return DanbooruArtistCommentaryRepositoryApi(
      ref.watch(danbooruClientProvider(config)),
    );
  },
);

final danbooruArtistCommentaryProvider =
    FutureProvider.autoDispose.family<ArtistCommentary, int>(
  (ref, postId) async {
    final config = ref.watchConfigAuth;
    final repo = ref.watch(danbooruArtistCommentaryRepoProvider(config));
    final commentary = await repo.getCommentary(postId);

    return commentary;
  },
);
