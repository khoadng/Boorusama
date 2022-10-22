// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PostData extends Equatable {
  const PostData({
    required this.post,
    required this.isFavorited,
    this.voteState = VoteState.unvote,
    required this.pools,
  });

  factory PostData.empty() => PostData(
        post: Post.empty(),
        isFavorited: false,
        pools: const [],
      );

  PostData copyWith({
    Post? post,
    bool? isFavorited,
    VoteState? voteState,
    List<Pool>? pools,
  }) =>
      PostData(
        post: post ?? this.post,
        isFavorited: isFavorited ?? this.isFavorited,
        voteState: voteState ?? this.voteState,
        pools: pools ?? this.pools,
      );

  final Post post;
  final bool isFavorited;
  final VoteState voteState;
  final List<Pool> pools;

  @override
  List<Object?> get props => [post, isFavorited, voteState, pools];
}
