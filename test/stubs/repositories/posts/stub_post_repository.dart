import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:dio/src/cancel_token.dart';
import 'package:hooks_riverpod/all.dart';

final stubPostProvider = Provider<IPostRepository>((ref) {
  return StubPostRepository();
});

class StubPostRepository implements IPostRepository {
  @override
  Future<List<Post>> getCuratedPosts(DateTime date, int page, TimeScale scale) {
    return Future.value([]);
  }

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) {
    return Future.value([]);
  }

  @override
  Future<List<Post>> getPopularPosts(DateTime date, int page, TimeScale scale) {
    return Future.value([]);
  }

  @override
  Future<List<Post>> getPosts(String tagString, int page,
      {int limit = 100,
      CancelToken cancelToken,
      bool skipFavoriteCheck = false}) {
    return Future.value([]);
  }
}
