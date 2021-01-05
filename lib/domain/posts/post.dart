import 'package:boorusama/domain/posts/created_time.dart';
import 'package:boorusama/domain/posts/rating.dart';
import 'package:boorusama/domain/posts/tag_string.dart';

import 'post_name.dart';

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
  final String _source;
  final String _createdAt;
  final int _score;
  final int _uploaderId;
  final int _upScore;
  final int _downScore;
  final String _rating;
  String _lastCommentAt;

  int favCount;
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
      this._lastCommentAt,
      this._source,
      this._createdAt,
      this._score,
      this._upScore,
      this._downScore,
      this.favCount,
      this._uploaderId,
      this._rating]);

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

  PostName get name {
    return PostName(
      tagStringArtist: tagStringArtist,
      tagStringCharacter: tagStringCharacter,
      tagStringCopyright: tagStringCopyright,
    );
  }

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

  String get source => _source;
  int get score => _score;
  int get upScore => _upScore;
  int get downScore => _downScore;
  CreatedTime get createdAt => CreatedTime(_createdAt);
  Rating get rating {
    if (_rating == "s") {
      return Rating.safe;
    } else if (_rating == "q") {
      return Rating.questionable;
    } else {
      return Rating.explicit;
    }
  }

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
      json["is_favorited"] ?? false,
      json["last_commented_at"],
      json["source"],
      json["created_at"],
      json["score"],
      json["up_score"],
      json["down_score"],
      json["fav_count"],
      json["uploader_id"],
      json["rating"],
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
