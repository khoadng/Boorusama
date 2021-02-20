// Package imports:
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/created_time.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/image_source.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/rating.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/tag_string.dart';
import 'package:boorusama/core/domain/i_downloadable.dart';
import 'post_name.dart';

class Post implements IDownloadable {
  final int id;
  final Uri previewImageUri;
  final Uri normalImageUri;
  final Uri fullImageUri;
  final String tagStringCopyright;
  final String tagStringCharacter;
  final String tagStringArtist;
  final String tagStringGeneral;
  final TagString tagString;
  final double width;
  final double height;
  final String format;
  final DateTime lastCommentAt;
  final ImageSource source;
  final CreatedTime createdAt;
  final int score;
  final int upScore;
  final int downScore;
  final int favCount;
  final int uploaderId;
  final Rating rating;
  final int fileSize;

  final bool isFavorited;

  Post({
    @required this.id,
    @required this.previewImageUri,
    @required this.normalImageUri,
    @required this.fullImageUri,
    @required this.tagStringCopyright,
    @required this.tagStringCharacter,
    @required this.tagStringArtist,
    @required this.tagStringGeneral,
    @required this.tagString,
    @required this.width,
    @required this.height,
    @required this.format,
    @required this.lastCommentAt,
    @required this.source,
    @required this.createdAt,
    @required this.score,
    @required this.upScore,
    @required this.downScore,
    @required this.favCount,
    @required this.uploaderId,
    @required this.rating,
    @required this.fileSize,
    //TODO: workaround
    this.isFavorited = false,
  });

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
    if (supportVideoFormat.contains(format)) {
      return true;
    } else {
      return false;
    }
  }

  bool get isAnimated {
    return isVideo || (format == "gif");
  }

  bool get isTranslated => tagString.contains("translated");

  bool get hasComment => lastCommentAt != null;

  @override
  String get fileName => "${name.full} - ${path.basename(downloadUrl)}"
      .fixInvalidCharacterForPathName();

  @override
  String get downloadUrl =>
      isVideo ? normalImageUri.toString() : fullImageUri.toString();

  factory Post.empty() => Post(
        id: 0,
        previewImageUri: null,
        normalImageUri: null,
        fullImageUri: null,
        tagStringCopyright: "",
        tagStringCharacter: "",
        tagStringArtist: "",
        tagStringGeneral: "",
        tagString: TagString(""),
        width: 1,
        height: 1,
        format: "png",
        lastCommentAt: null,
        source: ImageSource(""),
        createdAt: CreatedTime(DateTime.now().toIso8601String()),
        score: 0,
        upScore: 0,
        downScore: 0,
        favCount: 0,
        uploaderId: 0,
        rating: Rating(rating: "e"),
        fileSize: 0,
        isFavorited: false,
      );
}

extension InvalidFileCharsExtension on String {
  String fixInvalidCharacterForPathName() {
    return this.replaceAll(RegExp(r'[\\/*?:"<>|]'), "_");
  }
}
