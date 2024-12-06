// Package imports:
import 'package:equatable/equatable.dart';

class ArtistCommentary extends Equatable {
  const ArtistCommentary({
    required this.originalTitle,
    required this.originalDescription,
    required this.translatedTitle,
    required this.translatedDescription,
  });

  const ArtistCommentary.description(
    this.originalDescription,
  )   : originalTitle = '',
        translatedTitle = '',
        translatedDescription = '';

  const ArtistCommentary.empty()
      : originalTitle = '',
        originalDescription = '',
        translatedTitle = '',
        translatedDescription = '';

  final String originalTitle;
  final String originalDescription;
  final String translatedTitle;
  final String translatedDescription;

  bool get isTranslated =>
      translatedTitle.isNotEmpty || translatedDescription.isNotEmpty;
  bool get hasCommentary =>
      originalTitle.isNotEmpty || originalDescription.isNotEmpty;

  @override
  List<Object?> get props => [
        originalTitle,
        originalDescription,
        translatedDescription,
        translatedTitle,
      ];
}

extension DanbooruArtistCommentaryX on ArtistCommentary {
  bool get isEmpty => this == const ArtistCommentary.empty();

  ArtistCommentary copyWith({
    String? originalTitle,
    String? originalDescription,
    String? translatedTitle,
    String? translatedDescription,
  }) =>
      ArtistCommentary(
        originalTitle: originalTitle ?? this.originalTitle,
        originalDescription: originalDescription ?? this.originalDescription,
        translatedTitle: translatedTitle ?? this.translatedTitle,
        translatedDescription:
            translatedDescription ?? this.translatedDescription,
      );
}
