// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'local_providers.dart';

final danbooruArtistCommentaryProvider =
    FutureProvider.autoDispose.family<ArtistCommentary, int>(
  (ref, postId) async {
    final config = ref.watchConfigAuth;
    final repo = ref.watch(danbooruArtistCommentaryRepoProvider(config));
    final commentary = await repo.getCommentary(postId);

    return commentary;
  },
);
