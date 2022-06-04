// Package imports:
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/settings/settings.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class BlackListedFilterDecorator implements IPostRepository {
  BlackListedFilterDecorator({
    required IPostRepository postRepository,
    required Settings settings,
  })  : _postRepository = postRepository,
        _settings = settings;

  final IPostRepository _postRepository;
  final Settings _settings;

  @override
  Future<List<Post>> getCuratedPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getCuratedPosts(date, page, scale);
    final filtered = _filter(posts);
    return filtered;
  }

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) async {
    final posts = await _postRepository.getMostViewedPosts(date);
    final filtered = _filter(posts);
    return filtered;
  }

  @override
  Future<List<Post>> getPopularPosts(
      DateTime date, int page, TimeScale scale) async {
    final posts = await _postRepository.getPopularPosts(date, page, scale);
    final filtered = _filter(posts);
    return filtered;
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
    final filtered = _filter(posts);
    return filtered;
  }

  List<Post> _filter(List<Post> posts) {
    final settings = _settings;

    final tagRule = settings.blacklistedTags.split("\n");

    final filtered = posts.where((dto) {
      return dto.tagString
          .toString()
          .split(' ')
          .toSet()
          .intersection(tagRule.toSet())
          .isEmpty;
    }).toList();

    return filtered;
  }
}
