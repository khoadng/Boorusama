// Project imports:
import 'artist_url.dart';

abstract interface class DanbooruArtistUrlRepository {
  Future<List<DanbooruArtistUrl>> getArtistUrls(int artistId);
}
