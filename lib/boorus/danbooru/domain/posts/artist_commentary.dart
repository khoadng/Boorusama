import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'artist_commentary.g.dart';

@JsonSerializable()
class ArtistCommentary {
  final String original;
  final String translated;
  final String profileUrl;

  ArtistCommentary({@required this.original, this.translated, this.profileUrl});

  bool get isTranslated => translated != null;
  bool get hasCommentary => original != null;

  factory ArtistCommentary.empty() => ArtistCommentary(original: "");

  factory ArtistCommentary.fromJson(Map<String, dynamic> json) =>
      _$ArtistCommentaryFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistCommentaryToJson(this);
}
