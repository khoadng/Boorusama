// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

mixin DanbooruClientPosts {
  Dio get dio;

  Future<List<PostDto>> getPosts({
    int? page,
    int? limit,
    List<String>? tags,
  }) async {
    final response = await dio.get(
      '/posts.json',
      queryParameters: {
        if (tags != null && tags.isNotEmpty) 'tags': tags.join(' '),
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<PostVoteDto> votePost({
    required int postId,
    required int score,
  }) async {
    final response = await dio.post(
      '/posts/$postId/votes.json',
      queryParameters: {
        'score': score,
      },
    );

    return PostVoteDto.fromJson(response.data);
  }

  Future<PostVoteDto> upvotePost(int postId) => votePost(
        postId: postId,
        score: 1,
      );

  Future<PostVoteDto> downvotePost(int postId) => votePost(
        postId: postId,
        score: -1,
      );

  Future<void> removePostVote(
    int postId,
  ) async {
    final _ = await dio.delete(
      '/posts/$postId/votes.json',
    );
  }

  Future<List<PostVoteDto>> getPostVotes({
    int? page,
    required List<int> postIds,
    required int userId,
    bool? isDeleted,
    int limit = 100,
  }) async {
    if (postIds.isEmpty) {
      throw ArgumentError.value(postIds, 'postIds', 'Must not be empty');
    }

    final response = await dio.get(
      '/post_votes.json',
      queryParameters: {
        if (page != null) 'page': page,
        'search[post_id]': postIds.join(','),
        'search[user_id]': userId,
        if (isDeleted != null) 'search[is_deleted]': isDeleted,
        'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => PostVoteDto.fromJson(item))
        .toList();
  }
}
