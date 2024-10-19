class ArtistUrlDto {
  ArtistUrlDto({
    this.id,
    this.artistId,
    this.url,
    this.createdAt,
    this.updatedAt,
    this.isActive,
  });

  factory ArtistUrlDto.fromJson(Map<String, dynamic> json) {
    return ArtistUrlDto(
      id: json['id'],
      artistId: json['artist_id'],
      url: json['url'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isActive: json['is_active'],
    );
  }

  final int? id;
  final int? artistId;
  final String? url;
  final String? createdAt;
  final String? updatedAt;
  final bool? isActive;

  @override
  String toString() => url ?? '';
}
