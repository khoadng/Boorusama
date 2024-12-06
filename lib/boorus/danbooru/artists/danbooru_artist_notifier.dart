// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/core/configs.dart';

class DanbooruArtistNotifier
    extends FamilyAsyncNotifier<DanbooruArtist, String> {
  @override
  FutureOr<DanbooruArtist> build(String arg) {
    final config = ref.watchConfigAuth;
    return load(config);
  }

  Future<DanbooruArtist> load(BooruConfigAuth config) {
    return ref.read(danbooruArtistRepoProvider(config)).getArtist(arg);
  }
}
