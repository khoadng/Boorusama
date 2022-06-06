// Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class NoImageFilterDecorator implements IPostRepository {
  NoImageFilterDecorator({
    required IPostRepository postRepository,
  }) : _postRepository = postRepository;

  final IPostRepository _postRepository;

  @override
  Future<List<Post>> getCuratedPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getCuratedPosts(date, page, scale);
    return _filter(posts);
  }

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) async {
    final posts = await _postRepository.getMostViewedPosts(date);
    return _filter(posts);
  }

  @override
  Future<List<Post>> getPopularPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getPopularPosts(date, page, scale);
    return _filter(posts);
  }

  @override
  Future<List<Post>> getPosts(
    String tagString,
    int page, {
    int limit = 50,
    CancelToken? cancelToken,
    bool skipFavoriteCheck = false,
  }) async {
    final posts = await _postRepository.getPosts(tagString, page,
        limit: limit,
        cancelToken: cancelToken,
        skipFavoriteCheck: skipFavoriteCheck);
    return _filter(posts);
  }

  List<Post> _filter(List<Post> posts) {
    return posts
        .where((post) =>
            post.normalImageUri != null &&
            post.previewImageUri != null &&
            post.fullImageUri != null)
        .toList();
  }
}
