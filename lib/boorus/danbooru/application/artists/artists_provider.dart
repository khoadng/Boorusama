// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/artists.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/artists.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';

final danbooruArtistRepoProvider = Provider<ArtistRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);

  return ArtistRepositoryApi(api: api);
});

final danbooruArtistProvider =
    NotifierProvider.family<ArtistNotifier, Artist, String>(
  ArtistNotifier.new,
  dependencies: [
    danbooruArtistRepoProvider,
  ],
);
