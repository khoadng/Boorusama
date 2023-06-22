// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'danbooru_artist_commentary.dart';

abstract class DanbooruArtistCommentaryRepository {
  Future<DanbooruArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  });
}
