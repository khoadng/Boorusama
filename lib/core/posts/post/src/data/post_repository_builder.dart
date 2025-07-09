// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../http/http.dart';
import '../../../../search/queries/query.dart';
import '../../../../search/selected_tags/tag.dart';
import '../../../../settings/settings.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

class PostRepositoryBuilder<T extends Post> implements PostRepository<T> {
  PostRepositoryBuilder({
    required this.fetch,
    required this.fetchSingle,
    required this.getSettings,
    required this.getComposer,
    this.fetchFromController,
  });

  final TagQueryComposer Function() getComposer;

  final PostFutureFetcher<T> fetch;
  final PostSingleFutureFetcher<T> fetchSingle;
  final PostFutureControllerFetcher<T>? fetchFromController;
  final Future<ImageListingSettings> Function() getSettings;
  @override
  TagQueryComposer get tagComposer => getComposer();

  @override
  PostsOrError<T> getPosts(
    String tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => TaskEither.Do(($) async {
    var lim = limit;

    lim ??= await getSettings().then((value) => value.postsPerPage);

    final newTags = tags.isEmpty ? <String>[] : tags.split(' ');

    final tags2 = tagComposer.compose(newTags);

    return $(
      tryFetchRemoteData(
        fetcher: () => fetch(
          tags2,
          page,
          limit: lim,
          options: options,
        ),
      ),
    );
  });

  @override
  PostsOrError<T> getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => fetchFromController != null
      ? TaskEither.Do(($) async {
          var lim = limit;

          lim ??= await getSettings().then((value) => value.postsPerPage);

          return $(
            tryFetchRemoteData(
              fetcher: () => fetchFromController!(
                controller,
                page,
                limit: lim,
                options: options,
              ),
            ),
          );
        })
      : getPosts(
          controller.rawTagsString,
          page,
          limit: limit,
          options: options,
        );

  @override
  PostOrError<T> getPost(
    PostId id, {
    PostFetchOptions? options,
  }) => TaskEither.Do(($) async {
    return $(
      tryFetchRemoteData(
        fetcher: () => fetchSingle(
          id,
          options: options,
        ),
      ),
    );
  });
}
