class DanbooruArtistUrlDto {
  int? id;
  int? artistId;
  String? url;
  String? createdAt;
  String? updatedAt;
  bool? isActive;

  DanbooruArtistUrlDto({
    this.id,
    this.artistId,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  factory DanbooruArtistUrlDto.fromJson(Map<String, dynamic> json) {
    return DanbooruArtistUrlDto(
      id: json['id'],
      artistId: json['artist_id'],
      url: json['url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
    );
  }
}
