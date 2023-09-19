// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import 'types/types.dart';

const _kForumParams =
    'id,creator,updater,title,response_count,is_sticky,is_locked,created_at,updated_at,is_deleted,category_id,category_id,min_level,original_post';

const _kForumPostParams =
    'id,creator,updater,topic_id,body,created_at,updated_at,is_deleted,votes';

// const _kForumPostVoteParams =
//     'id,forum_post_id,score,created_at,updated_at,creator';

enum TopicOrder {
  sticky,
}

mixin DanbooruClientForums {
  Dio get dio;

  Future<List<ForumTopicDto>> getForumTopics({
    int? page,
    TopicOrder? order,
    int? limit,
  }) async {
    final response = await dio.get(
      '/forum_topics.json',
      queryParameters: {
        if (page != null) 'page': page,
        if (order != null) 'search[order]': order.name,
        if (limit != null) 'limit': limit,
        'only': _kForumParams,
      },
    );

    return (response.data as List)
        .map((item) => ForumTopicDto.fromJson(item))
        .toList();
  }

  Future<List<ForumPostDto>> getForumPosts({
    required int topicId,
    String? page,
    int? limit,
  }) async {
    final response = await dio.get(
      '/forum_posts.json',
      queryParameters: {
        'search[topic_id]': topicId,
        if (page != null) 'page': page,
        if (limit != null) 'limit': limit,
        'only': _kForumPostParams,
      },
    );

    return (response.data as List)
        .map((item) => ForumPostDto.fromJson(item))
        .toList();
  }

  Future<List<ForumPostVoteDto>> getForumPostVotes({
    required int forumPostId,
    int? limit,
    int? page,
  }) async {
    final response = await dio.get(
      '/forum_post_votes.json',
      queryParameters: {
        'search[forum_post_id]': forumPostId.toString(),
        // 'only': _kForumPostVoteParams,
        if (limit != null) 'limit': limit,
        if (page != null) 'page': page,
      },
    );

    return (response.data as List)
        .map((item) => ForumPostVoteDto.fromJson(item))
        .toList();
  }
}
