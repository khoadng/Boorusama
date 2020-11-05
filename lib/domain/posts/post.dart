import 'package:boorusama/domain/posts/tag_string.dart';

class Post {
  final int _id;
  final Uri _previewImageUri;
  final Uri _normalImageUri;
  final Uri _fullImageUri;
  final int _width;
  final int _height;
  // ignore: non_constant_identifier_names
  final String _tag_string_copyright;
  // ignore: non_constant_identifier_names
  final String _tag_string_character;
  // ignore: non_constant_identifier_names
  final String _tag_string_artist;
  // ignore: non_constant_identifier_names
  final String _tag_string;
  //TODO: should use Enum instead of raw string
  final String _format;
  String _lastCommentAt;
  bool isFavorited;

//TODO: fix naming from Image to Post
  Post(
      [this._id,
      this._previewImageUri,
      this._normalImageUri,
      this._fullImageUri,
      // ignore: non_constant_identifier_names
      this._tag_string_copyright,
      // ignore: non_constant_identifier_names
      this._tag_string_character,
      // ignore: non_constant_identifier_names
      this._tag_string_artist,
      // ignore: non_constant_identifier_names
      this._tag_string,
      this._width,
      this._height,
      this._format,
      this.isFavorited,
      this._lastCommentAt]);

  int get id => _id;

  Uri get previewImageUri => _previewImageUri;

  Uri get normalImageUri => _normalImageUri;

  Uri get fullImageUri => _fullImageUri;

  double get width => _width.toDouble();

  double get height => _height.toDouble();

  String get tagStringCopyright => _tag_string_copyright;

  String get tagStringCharacter => _tag_string_character;

  String get tagStringArtist => _tag_string_artist;

  TagString get tagString => TagString(_tag_string);

  double get aspectRatio => this.width / this.height;

  bool get isVideo {
    //TODO: handle other kind of video format
    final supportVideoFormat = ["mp4", "webm", "zip"];
    if (supportVideoFormat.contains(_format)) {
      return true;
    } else {
      return false;
    }
  }

  bool get isAnimated {
    return isVideo || (_format == "gif");
  }

  bool get isTranslated => tagString.contains("translated");

  bool get hasComment => _lastCommentAt != null;

  factory Post.fromJson(Map<String, dynamic> json) {
    //TODO: should use json deserialize library
    return new Post(
      json["id"],
      Uri.parse(json["preview_file_url"]),
      Uri.parse(json["large_file_url"]),
      Uri.parse(json["file_url"]),
      json["tag_string_copyright"],
      json["tag_string_character"],
      json["tag_string_artist"],
      json["tag_string"],
      json["image_width"],
      json["image_height"],
      json["file_ext"],
      json["is_favorited"],
      json["last_commented_at"],
    );
  }

  bool containsBlacklistedTag(String blacklistedTagString) {
    final tagRule = blacklistedTagString.split("\n");

    //TODO: should handle tag combination instead of a single tag
    for (var tags in tagRule) {
      if (tags.split(" ").length == 1) {
        if (tagString.contains(tags)) {
          return true;
        }
      }
    }

    return false;
  }
}
