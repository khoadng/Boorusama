// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs.dart';
import 'artist.dart';
import 'artist_repository.dart';
import 'artist_repository_api.dart';

final danbooruArtistRepoProvider =
    Provider.family<DanbooruArtistRepository, BooruConfigAuth>((ref, config) {
  return DanbooruArtistRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});

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
