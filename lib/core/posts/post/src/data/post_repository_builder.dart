// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../http/client/types.dart';
import '../../../../search/queries/types.dart';
import '../../../../search/selected_tags/types.dart';
import '../../../../settings/types.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

class PostRepositoryBuilder<T extends Post> implements PostRepository<T> {
  PostRepositoryBuilder({
    required this.fetch,
    required this.fetchSingle,
    required this.getSettings,
    required this.tagComposer,
    this.fetchFromController,
  });

  final PostFutureFetcher<T> fetch;
  final PostSingleFutureFetcher<T> fetchSingle;
  final PostFutureControllerFetcher<T>? fetchFromController;
  final Future<ImageListingSettings> Function() getSettings;
  @override
  final TagQueryComposer tagComposer;

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
      : TaskEither.Do(($) async {
          var lim = limit;

          lim ??= await getSettings().then((value) => value.postsPerPage);

          final tags = controller.tags.map((e) => e.originalTag).toList();
          final composedTags = tagComposer.compose(tags);

          return $(
            tryFetchRemoteData(
              fetcher: () => fetch(
                composedTags,
                page,
                limit: lim,
                options: options,
              ),
            ),
          );
        });

  @override
  PostOrError<T> getPost(
    PostId id, {
    PostFetchOptions? options,
  }) => TaskEither.Do(($) {
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
