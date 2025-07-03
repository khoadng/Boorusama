// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import '../../../../../../core/artists/types.dart';
import '../../../../../../foundation/caching.dart';
import '../types/artist_commentary_repository.dart';
import 'converter.dart';

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
      return const ArtistCommentary.empty();
    }
  }
}
