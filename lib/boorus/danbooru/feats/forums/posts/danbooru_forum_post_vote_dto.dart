class DanbooruForumPostVoteDto {
  final int? id;
  final int? forumPostId;
  final int? creatorId;
  final int? score;
  final String? createdAt;
  final String? updatedAt;

  DanbooruForumPostVoteDto({
    this.id,
    this.forumPostId,
    this.creatorId,
    this.score,
    this.createdAt,
    this.updatedAt,
  });

  factory DanbooruForumPostVoteDto.fromJson(Map<String, dynamic> json) {
    return DanbooruForumPostVoteDto(
      id: json['id'],
      forumPostId: json['forum_post_id'],
      creatorId: json['creator_id'],
      score: json['score'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
