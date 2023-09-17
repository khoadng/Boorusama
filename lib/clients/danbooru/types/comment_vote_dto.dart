class CommentVoteDto {
  CommentVoteDto({
    this.id,
    this.commentId,
    this.userId,
    this.score,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  factory CommentVoteDto.fromJson(Map<String, dynamic> json) => CommentVoteDto(
        id: json['id'],
        commentId: json['comment_id'],
        userId: json['user_id'],
        score: json['score'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        isDeleted: json['is_deleted'],
      );

  final int? id;
  final int? commentId;
  final int? userId;
  final int? score;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDeleted;

  @override
  String toString() => '$userId: $score';
}
