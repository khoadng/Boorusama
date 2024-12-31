// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';

// Project imports:
import 'artist.dart';

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
