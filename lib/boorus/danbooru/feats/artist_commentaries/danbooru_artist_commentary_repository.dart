// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/artist_commentaries/artist_commentaries.dart';

abstract class DanbooruArtistCommentaryRepository {
  Future<ArtistCommentary> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  });
}
