// Project imports:
import 'package:boorusama/api/danbooru/danbooru_api.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/danbooru_artist_parser.dart';
import 'package:boorusama/boorus/danbooru/feats/artists/danbooru_artist_url.dart';

abstract interface class DanbooruArtistUrlRepository {
  Future<List<DanbooruArtistUrl>> getArtistUrls(int artistId);
}

class DanbooruArtistUrlRepositoryApi implements DanbooruArtistUrlRepository {
  DanbooruArtistUrlRepositoryApi({
    required this.api,
  });

  final DanbooruApi api;

  @override
  Future<List<DanbooruArtistUrl>> getArtistUrls(int artistId) => api
      .getArtistUrls(artistId)
      .then(parseArtistUrls)
      .catchError((e) => <DanbooruArtistUrl>[]);
}
