// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../../../../core/artists/types.dart';

abstract class DanbooruArtistCommentaryRepository {
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  });
}
