// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

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

class DanbooruArtistsNotifier extends PagedNotifier<int, DanbooruArtist> {
  DanbooruArtistsNotifier({
    required Future<List<DanbooruArtist>> Function(int page, int limit) load,
  }) : super(
          load: (key, limit) => load(key, limit),
          nextPageKeyBuilder: (records, key, limit) =>
              (records == null || records.length < limit) ? null : key + 1,
        );
}
