const kLocalPostVoteId = -99;

abstract class PostVote {
  int get id;
  int get postId;
  int get score;
}

extension PostVoteX on PostVote {
  VoteState get voteState => VoteState.fromScore(score);

  bool get isOptimisticUpdateVote => id == kLocalPostVoteId;
}

enum VoteState {
  unvote,
  upvoted,
  downvoted;

  factory VoteState.fromScore(int score) => switch (score) {
    < 0 => VoteState.downvoted,
    > 0 => VoteState.upvoted,
    _ => VoteState.unvote,
  };
}

extension VoteStateX on VoteState {
  bool get isUpvoted => this == VoteState.upvoted;
  bool get isDownvoted => this == VoteState.downvoted;
  bool get isUnvote => this == VoteState.unvote;

  int get score => switch (this) {
    VoteState.upvoted => 1,
    VoteState.downvoted => -1,
    VoteState.unvote => 0,
  };
}
