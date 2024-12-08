// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import 'artist_parser.dart';
import 'artist_url.dart';

abstract interface class DanbooruArtistUrlRepository {
  Future<List<DanbooruArtistUrl>> getArtistUrls(int artistId);
}

class DanbooruArtistUrlRepositoryApi implements DanbooruArtistUrlRepository {
  DanbooruArtistUrlRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<DanbooruArtistUrl>> getArtistUrls(int artistId) => client
      .getArtistUrls(artistId: artistId)
      .then((urls) => urls.map(artistUrlDtoToArtistUrl).toList())
      .catchError((e) => <DanbooruArtistUrl>[]);
}
