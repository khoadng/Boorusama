// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

class ArtistNotifier extends FamilyAsyncNotifier<Artist, String> {
  @override
  FutureOr<Artist> build(String arg) {
    return load();
  }

  Future<Artist> load() {
    return ref.read(danbooruArtistRepoProvider).getArtist(arg);
  }
}
