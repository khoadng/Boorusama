// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/artists/artists.dart';

abstract class DanbooruArtistRepository {
  Future<DanbooruArtist> getArtist(
    String name, {
    CancelToken? cancelToken,
  });
}
