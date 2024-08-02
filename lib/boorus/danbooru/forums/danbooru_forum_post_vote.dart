// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruForumPostVote extends Equatable {
  const DanbooruForumPostVote({
    required this.id,
    required this.forumPostId,
    required this.creatorId,
    required this.score,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final int forumPostId;
  final int creatorId;
  final int score;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        forumPostId,
        creatorId,
        score,
        createdAt,
        updatedAt,
      ];
}

extension DanbooruForumPostVoteX on DanbooruForumPostVote {
  DanbooruForumPostVoteType get type => switch (score) {
        > 0 => DanbooruForumPostVoteType.upvote,
        < 0 => DanbooruForumPostVoteType.downvote,
        _ => DanbooruForumPostVoteType.unsure,
      };
}

enum DanbooruForumPostVoteType {
  upvote,
  downvote,
  unsure,
}
