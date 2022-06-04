// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'artist_commentary.g.dart';

@JsonSerializable()
class ArtistCommentary {
  final String originalTitle;
  final String originalDescription;
  final String translatedTitle;
  final String translatedDescription;

  ArtistCommentary(
      {required this.originalTitle,
      required this.originalDescription,
      required this.translatedTitle,
      required this.translatedDescription});

  bool get isTranslated =>
      translatedTitle.isNotEmpty || translatedDescription.isNotEmpty;
  bool get hasCommentary =>
      originalTitle.isNotEmpty || originalDescription.isNotEmpty;

  factory ArtistCommentary.empty() => ArtistCommentary(
      originalTitle: "",
      originalDescription: "",
      translatedTitle: "",
      translatedDescription: "");

  factory ArtistCommentary.fromJson(Map<String, dynamic> json) =>
      _$ArtistCommentaryFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCommentaryToJson(this);
}
