// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/clients/danbooru/danbooru_client.dart';
import 'package:boorusama/clients/danbooru/types/types.dart';
import 'package:boorusama/foundation/caching/caching.dart';
import 'danbooru_artist_commentary_repository.dart';

class DanbooruArtistCommentaryRepositoryApi
    with CacheMixin<ArtistCommentary>
    implements DanbooruArtistCommentaryRepository {
  DanbooruArtistCommentaryRepositoryApi(this.client);
  final DanbooruClient client;

  @override
  int get maxCapacity => 100;
  @override
  Duration get staleDuration => const Duration(minutes: 15);

  @override
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  }) async {
    final cached = get('$postId');
    if (cached != null) return cached;

    try {
      final data = await client.getFirstMatchingArtistCommentary(
        postId: postId,
        cancelToken: cancelToken,
      );

      final ac = artistCommentaryDtoToArtistCommentary(data);

      set('$postId', ac);
      return ac;
    } catch (e) {
      return const ArtistCommentary(
        originalTitle: '',
        originalDescription: '',
        translatedTitle: '',
        translatedDescription: '',
      );
    }
  }
}

ArtistCommentary artistCommentaryDtoToArtistCommentary(
  ArtistCommentaryDto? d,
) {
  if (d == null) {
    return const ArtistCommentary(
      originalTitle: '',
      originalDescription: '',
      translatedTitle: '',
      translatedDescription: '',
    );
  }

  return ArtistCommentary(
    originalTitle: d.originalTitle ?? '',
    originalDescription: d.originalDescription ?? '',
    translatedTitle: d.translatedTitle ?? '',
    translatedDescription: d.translatedDescription ?? '',
  );
}
