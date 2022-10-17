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
