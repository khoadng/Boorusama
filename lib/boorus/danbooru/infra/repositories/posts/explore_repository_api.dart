// Project imports:
import 'package:boorusama/api/danbooru/danbooru.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/dtos/dtos.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/handle_error.dart';
import 'package:boorusama/core/domain/posts/post_image_source_composer.dart';
import 'post_repository_api.dart';

class ExploreRepositoryApi implements ExploreRepository {
  const ExploreRepositoryApi({
    required this.api,
    required this.accountRepository,
    required this.postRepository,
    required this.urlComposer,
  });

  final AccountRepository accountRepository;
  final PostRepository postRepository;
  final DanbooruApi api;
  final ImageSourceComposer<PostDto> urlComposer;

  static const int _limit = 60;

  @override
  Future<List<Post>> getHotPosts(
    int page, {
    int? limit,
  }) =>
      postRepository.getPosts(
        'order:rank',
        page,
        limit: limit,
      );

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
          .then((e) => parsePost(e, urlComposer))
          .catchError((e) {
        handleError(e);

        return <Post>[];
      });

  @override
  Future<List<Post>> getPopularPosts(
    DateTime date,
    int page,
    TimeScale scale, {
    int? limit,
  }) =>
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
              limit ?? _limit,
            ),
          )
          .then((e) => parsePost(e, urlComposer))
          .catchError((e) {
        handleError(e);

        return <Post>[];
      });
}
