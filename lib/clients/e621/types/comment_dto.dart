class CommentDto {
  final int? id;
  final DateTime? createdAt;
  final int? postId;
  final int? creatorId;
  final String? body;
  final int? score;
  final DateTime? updatedAt;
  final int? updaterId;
  final bool? doNotBumpPost;
  final bool? isHidden;
  final bool? isSticky;
  final String? warningType;
  final int? warningUserId;
  final String? creatorName;
  final String? updaterName;

  CommentDto({
    this.id,
    this.createdAt,
    this.postId,
    this.creatorId,
    this.body,
    this.score,
    this.updatedAt,
    this.updaterId,
    this.doNotBumpPost,
    this.isHidden,
    this.isSticky,
    this.warningType,
    this.warningUserId,
    this.creatorName,
    this.updaterName,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      postId: json['post_id'],
      creatorId: json['creator_id'],
      body: json['body'],
      score: json['score'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      updaterId: json['updater_id'],
      doNotBumpPost: json['do_not_bump_post'],
      isHidden: json['is_hidden'],
      isSticky: json['is_sticky'],
      warningType: json['warning_type'],
      warningUserId: json['warning_user_id'],
      creatorName: json['creator_name'],
      updaterName: json['updater_name'],
    );
  }

  @override
  String toString() => body ?? '';
}
