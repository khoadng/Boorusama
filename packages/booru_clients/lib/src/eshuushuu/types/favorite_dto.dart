class FavoriteResponseDto {
  FavoriteResponseDto({
    this.message,
    this.favorited,
    this.favoritesCount,
  });

  final String? message;
  final bool? favorited;
  final int? favoritesCount;

  factory FavoriteResponseDto.fromJson(Map<String, dynamic> json) {
    return FavoriteResponseDto(
      message: json['message'] as String?,
      favorited: json['favorited'] as bool?,
      favoritesCount: json['favorites_count'] as int?,
    );
  }
}
