// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/artists/types.dart';
import '../../../../../../core/configs/config/types.dart';
import '../data/providers.dart';

final danbooruArtistCommentaryProvider = FutureProvider.autoDispose
    .family<ArtistCommentary, (BooruConfigAuth, int)>(
      (ref, params) async {
        final (config, postId) = params;
        final repo = ref.watch(danbooruArtistCommentaryRepoProvider(config));
        final commentary = await repo.getCommentary(postId);

        return commentary;
      },
    );
