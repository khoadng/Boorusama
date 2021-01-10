import 'package:boorusama/domain/posts/created_time.dart';
import 'package:boorusama/domain/posts/image_source.dart';
import 'package:boorusama/domain/posts/rating.dart';
import 'package:boorusama/domain/posts/tag_string.dart';

import 'post_name.dart';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'post.freezed.dart';

@freezed
abstract class Post with _$Post {
  const factory Post({
    @required int id,
    @required Uri previewImageUri,
    @required Uri normalImageUri,
    @required Uri fullImageUri,
    @required String tagStringCopyright,
    @required String tagStringCharacter,
    @required String tagStringArtist,
    @required TagString tagString,
    @required double width,
    @required double height,
    @required String format,
    @required @nullable DateTime lastCommentAt,
    @required ImageSource source,
    @required CreatedTime createdAt,
    @required int score,
    @required int upScore,
    @required int downScore,
    @required int favCount,
    @required int uploaderId,
    @required Rating rating,
  }) = _Post;
}

extension PostX on Post {
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
}
