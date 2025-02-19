// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/artists/artists.dart';
import '../../../../../../core/configs/ref.dart';
import '../data/providers.dart';

final danbooruArtistCommentaryProvider =
    FutureProvider.autoDispose.family<ArtistCommentary, int>(
  (ref, postId) async {
    final config = ref.watchConfigAuth;
    final repo = ref.watch(danbooruArtistCommentaryRepoProvider(config));
    final commentary = await repo.getCommentary(postId);

    return commentary;
  },
);
