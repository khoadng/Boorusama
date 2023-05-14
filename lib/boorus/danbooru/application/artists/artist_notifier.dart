// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'artists_provider.dart';

class ArtistNotifier extends FamilyNotifier<Artist, String> {
  @override
  Artist build(String arg) {
    load();
    return Artist.empty();
  }

  Future<void> load() async {
    state = await ref.read(danbooruArtistRepoProvider).getArtist(arg);
  }
}
