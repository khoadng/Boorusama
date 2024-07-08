// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/posts/posts.dart';

typedef PostVoteId = int;

class DanbooruPostVote extends Equatable implements PostVote {
  const DanbooruPostVote({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  factory DanbooruPostVote.empty() => DanbooruPostVote(
        id: -1,
        postId: -1,
        userId: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        score: -9999,
        isDeleted: false,
      );

  factory DanbooruPostVote.local({
    required int postId,
    required int score,
  }) =>
      DanbooruPostVote(
        id: -99,
        postId: postId,
        userId: -99,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        score: score,
        isDeleted: false,
      );

  @override
  final PostVoteId id;
  @override
  final int postId;
  final UserId userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  @override
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

extension PostVoteX on DanbooruPostVote {
  bool get isOptimisticUpdateVote =>
      id == DanbooruPostVote.local(postId: postId, score: score).id;

  DanbooruPostVote copyWith({
    PostVoteId? id,
    int? postId,
    UserId? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? score,
    bool? isDeleted,
  }) =>
      DanbooruPostVote(
        id: id ?? this.id,
        postId: postId ?? this.postId,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        score: score ?? this.score,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}
