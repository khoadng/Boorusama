// Package imports:
import 'package:equatable/equatable.dart';

class ArtistCommentary extends Equatable {
  const ArtistCommentary({
    required this.originalTitle,
    required this.originalDescription,
    required this.translatedTitle,
    required this.translatedDescription,
  });

  factory ArtistCommentary.empty() => const ArtistCommentary(
        originalTitle: '',
        originalDescription: '',
        translatedTitle: '',
        translatedDescription: '',
      );
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

extension ArtistCommentaryX on ArtistCommentary {
  bool get isEmpty => this == ArtistCommentary.empty();
}
