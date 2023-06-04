class ArtistCommentaryDto {
  ArtistCommentaryDto({
    required this.id,
    required this.postId,
    this.originalTitle,
    this.originalDescription,
    this.translatedTitle,
    this.translatedDescription,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ArtistCommentaryDto.fromJson(Map<String, dynamic> json) =>
      ArtistCommentaryDto(
        id: json['id'],
        postId: json['post_id'],
        originalTitle: json['original_title'],
        originalDescription: json['original_description'],
        translatedTitle: json['translated_title'],
        translatedDescription: json['translated_description'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  final int id;
  final int postId;
  final String? originalTitle;
  final String? originalDescription;
  final String? translatedTitle;
  final String? translatedDescription;
  final DateTime createdAt;
  final DateTime updatedAt;
}
