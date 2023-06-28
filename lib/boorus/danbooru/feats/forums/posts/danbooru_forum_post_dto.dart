// Project imports:
import 'package:boorusama/boorus/danbooru/feats/forums/forums.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';

class DanbooruForumPostDto {
  DanbooruForumPostDto({
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

  factory DanbooruForumPostDto.fromJson(Map<String, dynamic> json) =>
      DanbooruForumPostDto(
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
            ? List<DanbooruForumPostVoteDto>.from(
                json['votes'].map((x) => DanbooruForumPostVoteDto.fromJson(x)))
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
  final List<DanbooruForumPostVoteDto>? votes;
}
