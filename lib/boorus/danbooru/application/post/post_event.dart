// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'fetchers/fetchers.dart';

enum PostsOrder {
  popular,
  newest,
}

enum PostListCategory {
  popular,
  latest,
  mostViewed,
  curated,
  hot,
}

abstract class PostEvent extends Equatable {
  const PostEvent();
}

class PostFetched extends PostEvent {
  const PostFetched({
    required this.tags,
    required this.fetcher,
    this.category,
    this.order,
  });

  final String tags;
  final PostsOrder? order;
  final PostListCategory? category;
  final PostFetcher fetcher;

  @override
  List<Object?> get props => [tags, order, category, fetcher];
}

class PostRefreshed extends PostEvent {
  const PostRefreshed({
    this.tag,
    required this.fetcher,
    this.category,
    this.order,
  });

  final String? tag;
  final PostsOrder? order;
  final PostListCategory? category;
  final PostFetcher fetcher;

  @override
  List<Object?> get props => [tag, order, category, fetcher];
}

class PostFavoriteUpdated extends PostEvent {
  const PostFavoriteUpdated({
    required this.postId,
    required this.favorite,
  });

  final int postId;
  final bool favorite;

  @override
  List<Object?> get props => [postId, favorite];
}

class PostUpdated extends PostEvent {
  const PostUpdated({
    required this.post,
  });

  final PostData post;

  @override
  List<Object?> get props => [post];
}

class PostReset extends PostEvent {
  const PostReset();

  @override
  List<Object?> get props => [];
}
