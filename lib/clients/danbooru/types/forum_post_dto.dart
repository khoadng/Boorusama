// Project imports:
import 'forum_vote_dto.dart';

class ForumPostDto {
  ForumPostDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.body,
    this.isDeleted,
    this.topicId,
    this.creatorId,
    this.updaterId,
    this.votes,
  });

  factory ForumPostDto.fromJson(Map<String, dynamic> json) => ForumPostDto(
        id: json['id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        body: json['body'],
        isDeleted: json['is_deleted'],
        topicId: json['topic_id'],
        creatorId: json['creator_id'],
        updaterId: json['updater_id'],
        votes: json['votes'] != null
            ? List<ForumPostVoteDto>.from(
                json['votes'].map((x) => ForumPostVoteDto.fromJson(x)))
            : null,
      );

  final int? id;
  final String? createdAt;
  final String? updatedAt;
  final String? body;
  final bool? isDeleted;
  final int? topicId;
  final int? creatorId;
  final int? updaterId;
  final List<ForumPostVoteDto>? votes;

  @override
  String toString() => body ?? '';
}
