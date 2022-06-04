// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artist.dart';

abstract class IArtistRepository {
  Future<Artist> getArtist(
    String name, {
    CancelToken? cancelToken,
  });
}
