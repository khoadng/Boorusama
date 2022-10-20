// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostData extends Equatable {
  const PostData({
    required this.post,
    required this.isFavorited,
    this.voteState = VoteState.unvote,
  });

  factory PostData.empty() => PostData(
        post: Post.empty(),
        isFavorited: false,
      );

  PostData copyWith({
    Post? post,
    bool? isFavorited,
    VoteState? voteState,
  }) =>
      PostData(
        post: post ?? this.post,
        isFavorited: isFavorited ?? this.isFavorited,
        voteState: voteState ?? this.voteState,
      );

  final Post post;
  final bool isFavorited;
  final VoteState voteState;

  @override
  List<Object?> get props => [post, isFavorited, voteState];
}
