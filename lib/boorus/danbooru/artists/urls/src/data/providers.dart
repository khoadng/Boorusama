// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import '../../../../danbooru_provider.dart';
import '../types/artist_url_repository.dart';
import 'artist_url_repository_api.dart';

final danbooruArtistUrlRepoProvider =
    Provider.family<DanbooruArtistUrlRepository, BooruConfigAuth>(
  (ref, config) {
    return DanbooruArtistUrlRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);
