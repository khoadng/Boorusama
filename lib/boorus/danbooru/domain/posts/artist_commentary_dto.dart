// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/artist_commentary.dart';

part 'artist_commentary_dto.freezed.dart';
part 'artist_commentary_dto.g.dart';

@freezed
abstract class ArtistCommentaryDto with _$ArtistCommentaryDto {
  const factory ArtistCommentaryDto({
    @nullable int id,
    @nullable int post_id,
    @nullable String original_title,
    @nullable String original_description,
    @nullable String translated_title,
    @nullable String translated_description,
    @nullable String created_at,
    @nullable String updated_at,
  }) = _ArtistCommentaryDto;

  factory ArtistCommentaryDto.fromJson(Map<String, dynamic> json) =>
      _$ArtistCommentaryDtoFromJson(json);
}

extension ArtistCommentaryDtoX on ArtistCommentaryDto {
  ArtistCommentary toEntity() {
    return ArtistCommentary(
        originalTitle: original_title ?? "",
        originalDescription: original_description ?? "",
        translatedTitle: translated_title ?? "",
        translatedDescription: translated_description ?? "");
  }
}
