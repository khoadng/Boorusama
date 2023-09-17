// Project imports:
import 'creator_dto.dart';
import 'forum_vote_dto.dart';

class ForumPostDto {
  ForumPostDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.body,
    this.isDeleted,
    this.topicId,
    this.creator,
    this.updater,
    this.votes,
  });

  factory ForumPostDto.fromJson(Map<String, dynamic> json) => ForumPostDto(
        id: json['id'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        body: json['body'],
        isDeleted: json['is_deleted'],
        topicId: json['topic_id'],
        creator: json['creator'] != null
            ? CreatorDto.fromJson(json['creator'])
            : null,
        updater: json['updater'] != null
            ? CreatorDto.fromJson(json['updater'])
            : null,
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
  final CreatorDto? creator;
  final CreatorDto? updater;
  final List<ForumPostVoteDto>? votes;

  @override
  String toString() => body ?? '';
}
