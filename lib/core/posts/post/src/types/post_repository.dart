// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/error.dart';
import '../../../../search/queries/query.dart';
import '../../../../search/selected_tags/providers.dart';
import 'post.dart';

abstract class PostRepository<T extends Post> {
  PostsOrError<T> getPosts(
    String tags,
    int page, {
    int? limit,
  });

  PostsOrError<T> getPostsFromController(
    SelectedTagController controller,
    int page, {
    int? limit,
  });

  TagQueryComposer get tagComposer;
}

class PostResult<T extends Post> extends Equatable {
  const PostResult({
    required this.posts,
    required this.total,
  });

  PostResult.empty()
      : posts = <T>[],
        total = 0;

  PostResult<T> copyWith({
    List<T>? posts,
    int? Function()? total,
  }) =>
      PostResult(
        posts: posts ?? this.posts,
        total: total != null ? total() : this.total,
      );

  final List<T> posts;
  final int? total;

  @override
  List<Object?> get props => [posts, total];
}

extension PostResultX<T extends Post> on List<T> {
  PostResult<T> toResult({
    int? total,
  }) =>
      PostResult(
        posts: this,
        total: total,
      );
}

typedef PostFutureFetcher<T extends Post> = Future<PostResult<T>> Function(
  List<String> tags,
  int page, {
  int? limit,
});

typedef PostFutureControllerFetcher<T extends Post> = Future<PostResult<T>>
    Function(
  SelectedTagController controller,
  int page, {
  int? limit,
});

typedef PostsOrErrorCore<T extends Post>
    = TaskEither<BooruError, PostResult<T>>;

typedef PostsOrError<T extends Post> = PostsOrErrorCore<T>;
