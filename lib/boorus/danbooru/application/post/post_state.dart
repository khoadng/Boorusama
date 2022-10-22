// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostState extends Equatable
    implements InfiniteLoadState<PostData, PostState> {
  const PostState({
    required this.status,
    required this.posts,
    required this.filteredPosts,
    required this.page,
    required this.hasMore,
    this.exceptionMessage,
    required this.id,
  });

  factory PostState.initial() => const PostState(
        status: LoadStatus.initial,
        posts: [],
        filteredPosts: [],
        page: 1,
        hasMore: true,
        id: 0,
      );

  final List<PostData> posts;
  final List<PostData> filteredPosts;
  final LoadStatus status;
  @override
  List<PostData> get data => posts;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  bool get loading => status == LoadStatus.loading;
  @override
  bool get refreshing => status == LoadStatus.initial;

  final String? exceptionMessage;

  //TODO: quick hack to force rebuild...
  final double id;

  PostState copyWith({
    LoadStatus? status,
    List<PostData>? posts,
    List<PostData>? filteredPosts,
    int? page,
    bool? hasMore,
    String? exceptionMessage,
    double? id,
  }) =>
      PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        exceptionMessage: exceptionMessage ?? this.exceptionMessage,
        id: id ?? this.id,
      );

  @override
  List<Object?> get props =>
      [status, posts, filteredPosts, page, hasMore, exceptionMessage, id];

  @override
  PostState copyLoadState({
    required int page,
    required bool hasMore,
    required bool refreshing,
    required bool loading,
    required List<PostData> data,
  }) =>
      copyWith(
        page: page,
        hasMore: hasMore,
        status: refreshing
            ? LoadStatus.initial
            : loading
                ? LoadStatus.loading
                : LoadStatus.success,
        posts: [...data],
      );
}
