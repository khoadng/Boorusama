// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/provider.dart';
import 'artist_commentary_notifier.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider<ArtistCommentaryRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final currentUserBooruRepository =
        ref.watch(currentBooruConfigRepoProvider);

    return ArtistCommentaryRepositoryApi(api, currentUserBooruRepository);
  },
);

final danbooruArtistCommentaryProvider = NotifierProvider.autoDispose
    .family<ArtistCommentaryNotifier, ArtistCommentary, int>(
  ArtistCommentaryNotifier.new,
  dependencies: [
    danbooruArtistCommentaryRepoProvider,
  ],
);
