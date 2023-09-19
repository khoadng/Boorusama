// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kArtistParams =
    'id,created_at,name,updated_at,is_deleted,group_name,is_banned,other_names,urls';

mixin DanbooruClientArtists {
  Dio get dio;

  Future<List<ArtistDto>> getArtists({
    String? name,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/artists.json',
      queryParameters: {
        if (name != null) 'search[name]': name,
        'only': _kArtistParams,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => ArtistDto.fromJson(item))
        .toList();
  }

  Future<ArtistDto?> getFirstMatchingArtist({
    required String name,
    CancelToken? cancelToken,
  }) async {
    final artists = await getArtists(
      name: name,
      cancelToken: cancelToken,
    );

    if (artists.isEmpty) return null;

    return artists.first;
  }

  Future<List<ArtistCommentaryDto>> getArtistCommentaries({
    required int postId,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/artist_commentaries.json',
      queryParameters: {
        'search[post_id]': postId.toString(),
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => ArtistCommentaryDto.fromJson(item))
        .toList();
  }

  Future<ArtistCommentaryDto?> getFirstMatchingArtistCommentary({
    required int postId,
    CancelToken? cancelToken,
  }) async {
    final commentaries = await getArtistCommentaries(
      postId: postId,
      cancelToken: cancelToken,
    );

    if (commentaries.isEmpty) return null;

    return commentaries.first;
  }

  Future<List<ArtistUrlDto>> getArtistUrls({
    required int artistId,
    CancelToken? cancelToken,
  }) async {
    final response = await dio.get(
      '/artist_urls.json',
      queryParameters: {
        'search[artist_id]': artistId,
      },
      cancelToken: cancelToken,
    );

    return (response.data as List)
        .map((item) => ArtistUrlDto.fromJson(item))
        .toList();
  }
}
