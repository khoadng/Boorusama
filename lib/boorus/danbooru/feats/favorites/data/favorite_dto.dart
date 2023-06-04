class FavoriteDto {
  FavoriteDto({
    required this.id,
    required this.userId,
    required this.postId,
  });

  factory FavoriteDto.fromJson(Map<String, dynamic> json) => FavoriteDto(
        id: json['id'],
        userId: json['user_id'],
        postId: json['post_id'],
      );

  final int id;
  final int userId;
  final int postId;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'post_id': postId,
      };
}
