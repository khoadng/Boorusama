import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_artist_commentary_repository.dart';

import 'artist_commentary_cache.dart';

class ArtistCommentaryCacheDecorator implements IArtistCommentaryRepository {
  final IArtistCommentaryRepository _artistCommentaryRepository;
  final IArtistCommentaryCache _artistCommentaryCache;
  final String _endpoint;

  ArtistCommentaryCacheDecorator(this._artistCommentaryRepository,
      this._artistCommentaryCache, this._endpoint);

  Future<ArtistCommentary> getCommentary(int postId) async {
    final key = "$_endpoint+commentary+$postId";
    if (await _artistCommentaryCache.isExist(key) &&
        await _artistCommentaryCache.isExpired(key) == false) {
      final cache = _artistCommentaryCache.get(key);
      return Future.value(cache);
    } else {
      final commentary =
          await _artistCommentaryRepository.getCommentary(postId);
      _artistCommentaryCache.put(key, commentary, Duration(hours: 12));

      return commentary;
    }
  }
}
