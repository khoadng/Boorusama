class UserFeedbackDto {
  UserFeedbackDto({
    this.id,
    this.userId,
    this.creatorId,
    this.body,
    this.category,
    this.createdAt,
    this.updatedAt,
    this.isDeleted,
  });

  factory UserFeedbackDto.fromJson(Map<String, dynamic> json) =>
      UserFeedbackDto(
        id: json['id'],
        userId: json['user_id'],
        creatorId: json['creator_id'],
        body: json['body'],
        category: json['category'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at'],
        isDeleted: json['is_deleted'],
      );

  final int? id;
  final int? userId;
  final int? creatorId;
  final String? body;
  final String? category;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDeleted;
}
