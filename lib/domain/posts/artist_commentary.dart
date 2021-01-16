import 'package:meta/meta.dart';

class ArtistCommentary {
  final String original;
  final String translated;
  final String profileUrl;

  ArtistCommentary({@required this.original, this.translated, this.profileUrl});

  bool get isTranslated => translated != null;

  factory ArtistCommentary.empty() => ArtistCommentary(original: "");
}
