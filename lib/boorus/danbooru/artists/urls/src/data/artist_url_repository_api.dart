// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/artist_url.dart';
import '../types/artist_url_repository.dart';
import 'converter.dart';

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
