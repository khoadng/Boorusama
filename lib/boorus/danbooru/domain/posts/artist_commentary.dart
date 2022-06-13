// Package imports:
import 'package:json_annotation/json_annotation.dart';

part 'artist_commentary.g.dart';

@JsonSerializable()
class ArtistCommentary {
  ArtistCommentary({
    required this.originalTitle,
    required this.originalDescription,
    required this.translatedTitle,
    required this.translatedDescription,
  });

  factory ArtistCommentary.empty() => ArtistCommentary(
        originalTitle: '',
        originalDescription: '',
        translatedTitle: '',
        translatedDescription: '',
      );

  factory ArtistCommentary.fromJson(Map<String, dynamic> json) =>
      _$ArtistCommentaryFromJson(json);
  final String originalTitle;
  final String originalDescription;
  final String translatedTitle;
  final String translatedDescription;

  bool get isTranslated =>
      translatedTitle.isNotEmpty || translatedDescription.isNotEmpty;
  bool get hasCommentary =>
      originalTitle.isNotEmpty || originalDescription.isNotEmpty;

  Map<String, dynamic> toJson() => _$ArtistCommentaryToJson(this);
}
