// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class DanbooruArtistNotifier
    extends FamilyAsyncNotifier<DanbooruArtist, String> {
  @override
  FutureOr<DanbooruArtist> build(String arg) {
    final config = ref.watchConfig;
    return load(config);
  }

  Future<DanbooruArtist> load(BooruConfig config) {
    return ref.read(danbooruArtistRepoProvider(config)).getArtist(arg);
  }
}
