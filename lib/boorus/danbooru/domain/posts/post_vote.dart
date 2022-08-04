// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

typedef PostVoteId = int;

class PostVote extends Equatable {
  const PostVote({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  final PostVoteId id;
  final int postId;
  final UserId userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int score;
  final bool isDeleted;

  @override
  List<Object?> get props => [
        id,
        postId,
        userId,
        createdAt,
        updatedAt,
        score,
        isDeleted,
      ];
}
