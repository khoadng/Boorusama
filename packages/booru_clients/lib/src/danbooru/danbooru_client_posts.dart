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
        'page': ?page,
        'limit': ?limit,
      },
    );

    return (response.data as List)
        .map((item) => PostDto.fromJson(item))
        .toList();
  }

  Future<PostDto?> getPost(int id) async {
    final response = await dio.get('/posts/$id.json');

    if (response.data == null) return null;

    return PostDto.fromJson(response.data);
  }

  Future<PostDto> createPost({
    required int mediaAssetId,
    required String rating,
    required String source,
    required int uploadMediaAssetId,
    List<String>? tags,
    String? artistCommentaryTitle,
    String? artistCommentaryDesc,
    String? translatedCommentaryTitle,
    String? translatedCommentaryDesc,
    int? parentId,
  }) async {
    final response = await dio.post(
      '/posts.json',
      data: {
        'media_asset_id': mediaAssetId,
        'upload_media_asset_id': uploadMediaAssetId,
        'post[rating]': rating,
        if (tags != null && tags.isNotEmpty) 'post[tag_string]': tags.join(' '),
        'post[source]': source,
        'post[artist_commentary][original_title]': ?artistCommentaryTitle,
        'post[artist_commentary][original_description]': ?artistCommentaryDesc,
        'post[artist_commentary][translated_title]': ?translatedCommentaryTitle,
        'post[artist_commentary][translated_description]':
            ?translatedCommentaryDesc,
        'post[parent_id]': ?parentId,
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return PostDto.fromJson(response.data);
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

  Future<bool> removePostVote(
    PostVoteId id,
  ) async {
    try {
      final _ = await dio.delete(
        '/post_votes/$id.json',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<PostVoteDto>> getPostVotesFromUser({
    int? page,
    required List<int> postIds,
    required int userId,
    bool? isDeleted,
    int limit = 100,
  }) => getPostVotes(
    page: page,
    postIds: postIds,
    userId: userId,
    isDeleted: isDeleted,
    limit: limit,
  );

  Future<List<PostVoteDto>> getPostVotes({
    int? page,
    required List<int> postIds,
    int? userId,
    bool? isDeleted,
    int limit = 100,
  }) async {
    if (postIds.isEmpty) {
      throw ArgumentError.value(postIds, 'postIds', 'Must not be empty');
    }

    final response = await dio.get(
      '/post_votes.json',
      queryParameters: {
        'page': ?page,
        'search[post_id]': postIds.join(','),
        'search[user_id]': ?userId,
        'search[is_deleted]': ?isDeleted,
        'limit': limit,
      },
    );

    return (response.data as List)
        .map((item) => PostVoteDto.fromJson(item))
        .toList();
  }

  Future<PostDto> putTags({
    required int postId,
    required List<String> tags,
  }) async {
    final response = await dio.put(
      '/posts/$postId.json',
      queryParameters: {
        'post[tag_string]': tags.join(' '),
        'post[old_tag_string]': '',
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    return PostDto.fromJson(response.data);
  }
}
