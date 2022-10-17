// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/post_vote.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';

class PostVoteDto {
  PostVoteDto({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.score,
    required this.isDeleted,
  });

  factory PostVoteDto.fromJson(Map<String, dynamic> json) => PostVoteDto(
        id: json['id'],
        postId: json['post_id'],
        userId: json['user_id'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        score: json['score'],
        isDeleted: json['is_deleted'],
      );

  final int? id;
  final int? postId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? score;
  final bool? isDeleted;
}

PostVote postVoteDtoToPostVote(PostVoteDto d) {
  return PostVote(
    id: d.id ?? 0,
    postId: d.postId ?? 0,
    userId: UserId(d.userId ?? 0),
    createdAt: d.createdAt ?? DateTime.now(),
    updatedAt: d.updatedAt ?? DateTime.now(),
    score: d.score ?? 0,
    isDeleted: d.isDeleted ?? false,
  );
}
