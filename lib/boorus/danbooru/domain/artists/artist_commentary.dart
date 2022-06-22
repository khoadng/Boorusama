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
  final String originalTitle;
  final String originalDescription;
  final String translatedTitle;
  final String translatedDescription;

  bool get isTranslated =>
      translatedTitle.isNotEmpty || translatedDescription.isNotEmpty;
  bool get hasCommentary =>
      originalTitle.isNotEmpty || originalDescription.isNotEmpty;
}
