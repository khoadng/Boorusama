// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/ref.dart';
import 'data/providers.dart';
import 'types/artist_url.dart';

final danbooruArtistUrlProvider = FutureProvider.autoDispose
    .family<List<DanbooruArtistUrl>, int>((ref, artistId) async {
      final config = ref.watchConfigAuth;
      final repo = ref.watch(danbooruArtistUrlRepoProvider(config));

      return repo.getArtistUrls(artistId);
    });
