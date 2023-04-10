// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists.dart';

abstract class ArtistRepository {
  Future<Artist> getArtist(
    String name, {
    CancelToken? cancelToken,
  });
}
