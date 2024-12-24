// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../http/http.dart';
import '../../../../search/queries/query.dart';
import '../../../../search/selected_tags/providers.dart';
import '../../../../settings/settings.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

class PostRepositoryBuilder<T extends Post> implements PostRepository<T> {
  PostRepositoryBuilder({
    required this.fetch,
    required this.getSettings,
    required this.getComposer,
    this.fetchFromController,
  });

  final TagQueryComposer Function() getComposer;

  final PostFutureFetcher<T> fetch;
  final PostFutureControllerFetcher<T>? fetchFromController;
  final Future<ImageListingSettings> Function() getSettings;
  @override
  TagQueryComposer get tagComposer => getComposer();

  @override
  PostsOrError<T> getPosts(String tags, int page, {int? limit}) =>
      TaskEither.Do(($) async {
        var lim = limit;

        lim ??= await getSettings().then((value) => value.postsPerPage);

        final newTags = tags.isEmpty ? <String>[] : tags.split(' ');

        final tags2 = tagComposer.compose(newTags);

        return $(
          tryFetchRemoteData(
            fetcher: () => fetch(tags2, page, limit: lim),
          ),
        );
      });

  @override
  PostsOrError<T> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  }) =>
      fetchFromController != null
          ? TaskEither.Do(($) async {
              var lim = limit;

              lim ??= await getSettings().then((value) => value.postsPerPage);

              return $(
                tryFetchRemoteData(
                  fetcher: () =>
                      fetchFromController!(controller, page, limit: lim),
                ),
              );
            })
          : getPosts(
              controller.rawTagsString,
              page,
              limit: limit,
            );
}
