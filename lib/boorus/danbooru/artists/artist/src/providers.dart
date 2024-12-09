// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'artist_repository.dart';
import 'artist_repository_api.dart';

final danbooruArtistRepoProvider =
    Provider.family<DanbooruArtistRepository, BooruConfigAuth>((ref, config) {
  return DanbooruArtistRepositoryApi(
    client: ref.watch(danbooruClientProvider(config)),
  );
});
