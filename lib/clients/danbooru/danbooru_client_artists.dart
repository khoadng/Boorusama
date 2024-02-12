// Dart imports:
import 'dart:isolate';

// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kArtistParams =
    'id,created_at,name,updated_at,is_deleted,group_name,is_banned,other_names,urls';

const _kArtistWithTagsParams =
    'id,created_at,name,updated_at,is_deleted,group_name,is_banned,other_names,urls,tag';

enum ArtistOrder {
  recentCreated,
  lastUpdated,
  name,
  count,
}

mixin DanbooruClientArtists {
  Dio get dio;

  Future<List<ArtistDto>> getArtists({
    String? name,
    String? url,
    bool? isDeleted,
    bool? isBanned,
    bool? hasTag,
    bool? includeTag,
    ArtistOrder? order,
    CancelToken? cancelToken,
    int? page,
  }) async {
    final response = await dio.get(
      '/artists.json',
      queryParameters: {
        if (name != null) 'search[any_name_matches]': name,
        if (url != null) 'search[url_matches]': url,
        if (isDeleted != null) 'search[is_deleted]': isDeleted,
        if (isBanned != null) 'search[is_banned]': isBanned,
        if (hasTag != null) 'search[has_tag]': hasTag,
        if (order != null)
          'search[order]': switch (order) {
            ArtistOrder.recentCreated => 'created_at',
            ArtistOrder.lastUpdated => 'updated_at',
            ArtistOrder.name => 'name',
            ArtistOrder.count => 'post_count',
          },
        if (page != null) 'page': page,
        'only': includeTag == true ? _kArtistWithTagsParams : _kArtistParams,
      },
      cancelToken: cancelToken,
    );

    return Isolate.run(() => (response.data as List)
        .map((item) => ArtistDto.fromJson(item))
        .toList());
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

    final nonDeleted = artists.where((e) => !e.isDeleted).toList();

    if (nonDeleted.isEmpty) return null;

    return nonDeleted.first;
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

    return Isolate.run(() => (response.data as List)
        .map((item) => ArtistCommentaryDto.fromJson(item))
        .toList());
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
