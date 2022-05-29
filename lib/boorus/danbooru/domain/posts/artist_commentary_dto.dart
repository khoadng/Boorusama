// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';

class ArtistCommentaryDto {
  ArtistCommentaryDto({
    this.id,
    this.postId,
    this.originalTitle,
    this.originalDescription,
    this.translatedTitle,
    this.translatedDescription,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int postId;
  final String originalTitle;
  final String originalDescription;
  final String translatedTitle;
  final String translatedDescription;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory ArtistCommentaryDto.fromJson(Map<String, dynamic> json) =>
      ArtistCommentaryDto(
        id: json["id"],
        postId: json["post_id"],
        originalTitle: json["original_title"],
        originalDescription: json["original_description"],
        translatedTitle: json["translated_title"],
        translatedDescription: json["translated_description"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );
}

extension ArtistCommentaryDtoX on ArtistCommentaryDto {
  ArtistCommentary toEntity() {
    return ArtistCommentary(
        originalTitle: originalTitle ?? "",
        originalDescription: originalDescription ?? "",
        translatedTitle: translatedTitle ?? "",
        translatedDescription: translatedDescription ?? "");
  }
}
