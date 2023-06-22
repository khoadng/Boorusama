// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

class DanbooruArtistNotifier
    extends FamilyAsyncNotifier<DanbooruArtist, String> {
  @override
  FutureOr<DanbooruArtist> build(String arg) {
    return load();
  }

  Future<DanbooruArtist> load() {
    return ref.read(danbooruArtistRepoProvider).getArtist(arg);
  }
}
