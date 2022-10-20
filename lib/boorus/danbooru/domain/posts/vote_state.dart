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
