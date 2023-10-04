// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'danbooru_artist_commentaries_provider.dart';

class DanbooruArtistCommentariesNotifier
    extends FamilyNotifier<Map<int, ArtistCommentary>, BooruConfig> {
  @override
  Map<int, ArtistCommentary> build(BooruConfig arg) {
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
        .read(danbooruArtistCommentaryRepoProvider(arg))
        .getCommentary(postId);

    _cache.set(postId.toString(), commentary);

    state = {
      ...state,
      postId: commentary,
    };
  }
}
