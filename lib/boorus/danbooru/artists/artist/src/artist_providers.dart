// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'artist.dart';
import 'providers.dart';

final danbooruArtistProvider = AsyncNotifierProvider.family<
    DanbooruArtistNotifier, DanbooruArtist, String>(
  DanbooruArtistNotifier.new,
);

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
