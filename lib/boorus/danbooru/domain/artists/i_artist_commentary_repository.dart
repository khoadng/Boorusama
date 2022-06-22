// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/artists/artists.dart';

abstract class IArtistCommentaryRepository {
  Future<ArtistCommentaryDto> getCommentary(
    int postId, {
    CancelToken? cancelToken,
  });
}
