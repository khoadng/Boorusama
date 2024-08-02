// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/core/artists/artists.dart';

abstract class DanbooruArtistCommentaryRepository {
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  });
}
