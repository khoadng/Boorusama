class CommentDto {
  final int? id;
  final String? createdAt;
  final int? postId;
  final String? creator;
  final int? creatorId;
  final String? body;

  CommentDto({
    this.id,
    this.createdAt,
    this.postId,
    this.creator,
    this.creatorId,
    this.body,
  });

  factory CommentDto.fromJson(Map<String, dynamic> json) {
    return CommentDto(
      id: json['id'],
      createdAt: json['created_at'],
      postId: json['post_id'],
      creator: json['creator'],
      creatorId: json['creator_id'],
      body: json['body'],
    );
  }

  @override
  String toString() => body ?? '';
}
