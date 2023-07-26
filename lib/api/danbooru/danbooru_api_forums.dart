// Package imports:
import 'package:retrofit/retrofit.dart';

mixin DanbooruApiForums {
  @GET('/forum_topics.json')
  Future<HttpResponse> getForumTopics({
    @Query('page') int? page,
    @Query('search[order]') String? order,
    @Query('limit') int? limit,
    @Query('only') String? only,
  });

  @GET('/forum_posts.json')
  Future<HttpResponse> getForumPosts({
    @Query('page') String? page,
    @Query('search[topic_id]') int? topicId,
    @Query('limit') int? limit,
    @Query('only') String? only,
  });

  @GET('/forum_post_votes.json')
  Future<HttpResponse> getForumPostVotes({
    @Query('search[forum_post_id]') int? forumPostId,
    @Query('only') String? only,
  });
}
