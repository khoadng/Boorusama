// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/domain/gelbooru_post.dart';
import 'package:boorusama/core/domain/posts.dart';

class GelbooruPostDetailState extends Equatable {
  const GelbooruPostDetailState({
    required this.currentIndex,
    required this.currentPost,
    required this.nextPost,
    required this.previousPost,
    required this.recommends,
  });

  factory GelbooruPostDetailState.initial() => GelbooruPostDetailState(
        currentIndex: 0,
        currentPost: GelbooruPost.empty(),
        previousPost: null,
        nextPost: null,
        recommends: const [],
      );

  final int currentIndex;
  final Post currentPost;
  final Post? nextPost;
  final Post? previousPost;
  final List<Recommend> recommends;

  GelbooruPostDetailState copyWith({
    int? currentIndex,
    Post? currentPost,
    Post? Function()? nextPost,
    Post? Function()? previousPost,
    List<Recommend>? recommends,
  }) =>
      GelbooruPostDetailState(
        currentIndex: currentIndex ?? this.currentIndex,
        currentPost: currentPost ?? this.currentPost,
        nextPost: nextPost != null ? nextPost() : this.nextPost,
        previousPost: previousPost != null ? previousPost() : this.previousPost,
        recommends: recommends ?? this.recommends,
      );

  @override
  List<Object?> get props => [
        currentIndex,
        currentPost,
        nextPost,
        previousPost,
        recommends,
      ];
}

extension PostDetailX on GelbooruPostDetailState {
  bool hasNext() => nextPost != null;
  bool hasPrevious() => previousPost != null;
}
