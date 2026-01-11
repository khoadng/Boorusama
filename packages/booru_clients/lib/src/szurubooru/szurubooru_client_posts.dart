// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kUpvoteScore = 1;
const _kDownvoteScore = -1;
const _kUnvoteScore = 0;

typedef SzurubooruPosts = ({List<PostDto> posts, int? total});

mixin SzurubooruClientPosts {
  Dio get dio;
  String get baseUrl;

  Future<SzurubooruPosts> getPosts({
    int? limit,
    int? page,
    List<String>? tags,
  }) async {
    final response = await dio.get(
      'api/posts',
      queryParameters: {
        if (limit != null) 'limit': limit,
        if (page != null && page > 0) 'offset': (page - 1) * (limit ?? 100),
        if (tags != null && tags.isNotEmpty) 'query': tags.join(' '),
      },
    );

    final results = response.data['results'] as List;
    final total = response.data['total'] as int?;

    final posts = results
        .map(
          (e) => PostDto.fromJson(
            e,
            baseUrl: baseUrl,
          ),
        )
        .toList();

    return (
      posts: posts,
      total: total,
    );
  }

  Future<PostDto?> getPost(int id) async {
    final response = await dio.get('api/post/$id');

    return PostDto.fromJson(
      response.data,
      baseUrl: baseUrl,
    );
  }

  Future<PostDto> upvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      'api/post/$postId/score',
      data: {
        'score': _kUpvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: baseUrl,
    );
  }

  Future<PostDto> downvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      'api/post/$postId/score',
      data: {
        'score': _kDownvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: baseUrl,
    );
  }

  Future<PostDto> unvotePost({
    required int postId,
  }) async {
    final response = await dio.put(
      'api/post/$postId/score',
      data: {
        'score': _kUnvoteScore,
      },
    );

    return PostDto.fromJson(
      response.data,
      baseUrl: baseUrl,
    );
  }
}
