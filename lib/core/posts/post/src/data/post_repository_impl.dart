// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../search/queries/query.dart';
import '../../../../search/selected_tags/tag.dart';
import '../types/post.dart';
import '../types/post_repository.dart';

class EmptyPostRepository extends PostRepository {
  EmptyPostRepository();

  @override
  PostsOrError getPosts(
    String tags,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => TaskEither.right(PostResult.empty());

  @override
  PostsOrError getPostsFromController(
    SearchTagSet controller,
    int page, {
    int? limit,
    PostFetchOptions? options,
  }) => TaskEither.right(PostResult.empty());

  @override
  PostOrError<Post> getPost(PostId id, {PostFetchOptions? options}) =>
      TaskEither.right(null);

  @override
  final TagQueryComposer tagComposer = EmptyTagQueryComposer();
}
