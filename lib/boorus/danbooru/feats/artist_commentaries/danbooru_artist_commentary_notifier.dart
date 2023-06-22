// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/foundation/caching/caching.dart';
import 'danbooru_artist_commentaries_provider.dart';
import 'danbooru_artist_commentary.dart';

class DanbooruArtistCommentariesNotifier
    extends Notifier<Map<int, DanbooruArtistCommentary>> {
  @override
  Map<int, DanbooruArtistCommentary> build() {
    return {};
  }

  final _cache = Cache<DanbooruArtistCommentary>(
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
