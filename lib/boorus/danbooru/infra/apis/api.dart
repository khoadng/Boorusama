// Package imports:
import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';

abstract class Api {
  Future<HttpResponse> addToFavorites(
    String login,
    String apiKey,
    int postId,
  );

  Future<HttpResponse> removeFromFavorites(
    int postId,
    String login,
    String apiKey,
    String method,
  );

  Future<HttpResponse> filterFavoritesFromUserId(
    String login,
    String apiKey,
    String postIdsStringComma,
    int userId,
    int limit,
  );

  Future<HttpResponse> getFavorites(
    int postId,
    int page,
    int limit,
  );

  Future<HttpResponse> getArtist(
    String name, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getComments(
    int postId,
    int limit, {
    String? only,
    CancelToken? cancelToken,
  });

  Future<HttpResponse> postComment(
    String login,
    String apiKey,
    int postId,
    String content,
    bool doNotBumpPost,
  );

  Future<HttpResponse> updateComment(
    String login,
    String apiKey,
    int commentId,
    String content,
  );

  Future<HttpResponse> deleteComment(
    String login,
    String apiKey,
    int commentId,
  );

  Future<HttpResponse> getCommentVotes(
    String login,
    String apiKey,
    String commentIdComma,
    bool isDeleted,
  );

  Future<HttpResponse> voteComment(
    String login,
    String apiKey,
    int commentId,
    int score,
  );

  Future<HttpResponse> removeVoteComment(
    String login,
    String apiKey,
    int commentId,
  );

  Future<HttpResponse> getNotes(
    int postId, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getPost(
    String login,
    String apiKey,
    int id,
  );

  Future<HttpResponse> getArtistCommentary(
    String login,
    String apiKey,
    int postId, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getProfile(
    String login,
    String apiKey, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getPosts(
    String login,
    String apiKey,
    int page,
    String tags,
    int limit, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getPopularPosts(
    String login,
    String apiKey,
    String date,
    String scale,
    int page,
    int limit,
  );

  Future<HttpResponse> getCuratedPosts(
    String login,
    String apiKey,
    String date,
    String scale,
    int page,
    int limit,
  );

  Future<HttpResponse> getMostViewedPosts(
    String login,
    String apiKey,
    String date,
  );

  Future<HttpResponse> getPopularSearchByDate(
    String login,
    String apiKey,
    String date,
  );

  Future<HttpResponse> getTagsByNamePattern(
    String login,
    String apiKey,
    int page,
    String hideEmpty,
    String stringPattern,
    String order,
    int limit,
  );

  Future<HttpResponse> getTagsByNameComma(
    String login,
    String apiKey,
    int page,
    String hideEmpty,
    String stringComma,
    String order,
    int limit, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getUsersByIdStringComma(
    String idComma,
    int limit, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getUserById(
    String login,
    String apiKey,
    int id,
  );

  Future<HttpResponse> setBlacklistedTags(
    String login,
    String apiKey,
    int id,
    String blacklistedTags, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getWiki(
    String subject, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getPools(
    String login,
    String apiKey,
    int page,
    int limit, {
    String? category,
    String? order,
    String? name,
    String? description,
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getPoolsFromPostId(
    String login,
    String apiKey,
    int postId,
    int limit, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> autocomplete(
    String login,
    String apiKey,
    String query,
    String type,
    int limit, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> getRelatedTag(
    String query, {
    CancelToken? cancelToken,
  });

  Future<HttpResponse> votePost(
    String login,
    String apiKey,
    int postId,
    int score,
  );

  Future<HttpResponse> removeVotePost(
    String login,
    String apiKey,
    int postId,
  );

  Future<HttpResponse> getPostVotes(
    String login,
    String apiKey,
    int page,
    String postIdComma,
    String userId,
    bool isDeleted,
    int limit,
  );
}
