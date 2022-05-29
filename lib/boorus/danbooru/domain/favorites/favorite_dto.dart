class FavoriteDto {
  FavoriteDto({
    this.id,
    this.userId,
    this.postId,
  });

  final int id;
  final int userId;
  final int postId;

  factory FavoriteDto.fromJson(Map<String, dynamic> json) => FavoriteDto(
        id: json["id"],
        userId: json["user_id"],
        postId: json["post_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "post_id": postId,
      };
}
