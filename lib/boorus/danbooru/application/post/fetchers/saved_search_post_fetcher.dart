// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/saved_searches/saved_searches.dart';
import 'fetcher.dart';

class SavedSearchPostFetcher implements PostFetcher {
  const SavedSearchPostFetcher(this.savedSearch);

  final SavedSearch savedSearch;

  @override
  Future<List<Post>> fetch(
    PostRepository repo,
    int page, {
    int? limit,
  }) async {
    var posts = await repo.getPosts(
      savedSearch.toQuery(),
      page,
      limit: limit,
    );

    if (posts.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
      posts = await repo.getPosts(
        savedSearch.toQuery(),
        page,
        limit: limit,
      );
    }

    return posts;
  }
}
