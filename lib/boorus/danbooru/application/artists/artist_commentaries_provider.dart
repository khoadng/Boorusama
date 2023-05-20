// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'artist_commentary_notifier.dart';

final danbooruArtistCommentaryRepoProvider =
    Provider<ArtistCommentaryRepository>(
  (ref) {
    final api = ref.watch(danbooruApiProvider);
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return ArtistCommentaryRepositoryApi(api, booruConfig);
  },
);

final danbooruArtistCommentaryProvider = NotifierProvider.autoDispose
    .family<ArtistCommentaryNotifier, ArtistCommentary, int>(
  ArtistCommentaryNotifier.new,
  dependencies: [
    danbooruArtistCommentaryRepoProvider,
  ],
);
