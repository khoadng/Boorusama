// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/clients/danbooru/danbooru_client_artists.dart';

abstract class DanbooruArtistRepository {
  Future<DanbooruArtist> getArtist(
    String name, {
    CancelToken? cancelToken,
  });

  Future<List<DanbooruArtist>> getArtists({
    String? name,
    String? url,
    bool? isDeleted,
    bool? isBanned,
    bool? hasTag,
    bool? includeTag,
    ArtistOrder? order,
    CancelToken? cancelToken,
    int? page,
  });
}
