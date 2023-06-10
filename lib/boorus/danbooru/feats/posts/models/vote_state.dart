enum VoteState {
  unvote,
  upvoted,
  downvoted,
}

VoteState voteStateFromScore(int score) {
  if (score == 0) return VoteState.unvote;
  if (score < 0) return VoteState.downvoted;

  return VoteState.upvoted;
}

extension VoteStateX on VoteState {
  bool get isUpvoted => this == VoteState.upvoted;
  bool get isDownvoted => this == VoteState.downvoted;
  bool get isUnvote => this == VoteState.unvote;

  int get score => switch (this) {
        VoteState.upvoted => 1,
        VoteState.downvoted => -1,
        VoteState.unvote => 0
      };
}
