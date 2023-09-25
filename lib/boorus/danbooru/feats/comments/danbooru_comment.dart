// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

typedef CommentId = int;
typedef CommentScore = int;
typedef CommentBody = String;
typedef CommentCreatorId = int;
typedef CommentPostId = int;

enum CommentVoteState {
  unvote,
  downvoted,
  upvoted,
}

class DanbooruComment extends Equatable {
  const DanbooruComment({
    required this.id,
    required this.score,
    required this.body,
    required this.postId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.creator,
  });

  factory DanbooruComment.emty() => DanbooruComment(
        id: -1,
        score: 0,
        body: '',
        postId: -1,
        createdAt: DateTime(1),
        updatedAt: DateTime(1),
        isDeleted: false,
        creator: null,
      );

  final CommentId id;
  final CommentScore score;
  final CommentBody body;
  final CommentPostId postId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final User? creator;

  @override
  List<Object?> get props => [
        id,
        score,
        body,
        postId,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}

extension CommentX on DanbooruComment {
  bool get isEdited => createdAt != updatedAt;

  DanbooruComment copyWith({
    CommentId? id,
    bool? isDeleted,
    String? body,
    int? score,
  }) =>
      DanbooruComment(
        id: id ?? this.id,
        score: score ?? this.score,
        body: body ?? this.body,
        postId: postId,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isDeleted: isDeleted ?? this.isDeleted,
        creator: creator,
      );
}

List<DanbooruComment> Function(List<DanbooruComment> comments)
    filterDeleted() =>
        (comments) => comments.where((e) => !e.isDeleted).toList();
