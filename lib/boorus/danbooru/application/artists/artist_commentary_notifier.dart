// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'artist_commentaries_provider.dart';

class ArtistCommentaryNotifier
    extends AutoDisposeFamilyNotifier<ArtistCommentary, int> {
  @override
  ArtistCommentary build(int arg) {
    load();
    return ArtistCommentary.empty();
  }

  Future<void> load() async {
    state =
        await ref.read(danbooruArtistCommentaryRepoProvider).getCommentary(arg);
  }
}
