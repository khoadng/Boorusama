// Package imports:
import 'package:equatable/equatable.dart';

class DanbooruArtistCommentary extends Equatable {
  const DanbooruArtistCommentary({
    required this.originalTitle,
    required this.originalDescription,
    required this.translatedTitle,
    required this.translatedDescription,
  });

  factory DanbooruArtistCommentary.empty() => const DanbooruArtistCommentary(
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

extension DanbooruArtistCommentaryX on DanbooruArtistCommentary {
  bool get isEmpty => this == DanbooruArtistCommentary.empty();
}
