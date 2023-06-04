// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/artists/artists.dart';
import 'package:boorusama/core/cache_mixin.dart';

class ArtistCommentariesNotifier extends Notifier<Map<int, ArtistCommentary>> {
  @override
  Map<int, ArtistCommentary> build() {
    return {};
  }

  final _cache = Cache<ArtistCommentary>(
    maxCapacity: 100,
    staleDuration: const Duration(minutes: 5),
  );

  Future<void> load(int postId) async {
    final cached = _cache.get(postId.toString());
    if (cached != null) return;

    final commentary = await ref
        .read(danbooruArtistCommentaryRepoProvider)
        .getCommentary(postId);

    _cache.set(postId.toString(), commentary);

    state = {
      ...state,
      postId: commentary,
    };
  }
}
