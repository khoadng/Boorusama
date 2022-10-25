// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/handle_error.dart';
import 'post_repository_api.dart';

class ExploreRepositoryApi implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.accountRepository,
    required this.postRepository,
  });

  final AccountRepository accountRepository;
  final PostRepository postRepository;
  final Api api;

  static const int _limit = 60;

  @override
  Future<List<Post>> getCuratedPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) =>
      accountRepository
          .get()
          .then(
            (account) => api.getCuratedPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              postParams,
              _limit,
            ),
          )
          .then(parsePost)
          .catchError((e) {
        handleError(e);
      });

  @override
  Future<List<Post>> getHotPosts(int page) =>
      postRepository.getPosts('order:rank', page);

  @override
  Future<List<Post>> getMostViewedPosts(
    DateTime date,
  ) =>
      accountRepository
          .get()
          .then(
            (account) => api.getMostViewedPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              postParams,
            ),
          )
          .then(parsePost)
          .catchError((e) {
        handleError(e);
      });

  @override
  Future<List<Post>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale,
  ) =>
      accountRepository
          .get()
          .then(
            (account) => api.getPopularPosts(
              account.username,
              account.apiKey,
              '${date.year}-${date.month}-${date.day}',
              scale.toString().split('.').last,
              page,
              postParams,
              _limit,
            ),
          )
          .then(parsePost)
          .catchError((e) {
        handleError(e);
      });
}
