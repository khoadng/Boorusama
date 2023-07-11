// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

abstract class Post extends Equatable
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin {
  int get id;
  DateTime? get createdAt;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  List<String> get tags;
  Rating get rating;
  bool get hasComment;
  bool get isTranslated;
  bool get hasParentOrChildren;
  PostSource get source;
  int get score;

  String getLink(String baseUrl);
  Uri getUriLink(String baseUrl);
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

  String thumbnailFromSettings(Settings settings) =>
      switch (settings.imageQuality) {
        ImageQuality.automatic => thumbnailImageUrl,
        ImageQuality.low => thumbnailImageUrl,
        ImageQuality.high => isVideo ? thumbnailImageUrl : sampleImageUrl,
        ImageQuality.highest => isVideo ? thumbnailImageUrl : sampleImageUrl,
        ImageQuality.original => isVideo ? thumbnailImageUrl : originalImageUrl
      };

  bool get hasNoImage =>
      thumbnailImageUrl.isEmpty &&
      sampleImageUrl.isEmpty &&
      originalImageUrl.isEmpty;
}

extension PostX on Post {
  List<Tag> extractTags() {
    final tags = <Tag>[];

    for (final t in this.tags) {
      tags.add(Tag(name: t, category: TagCategory.general, postCount: 0));
    }

    return tags;
  }

  bool containsTagPattern(String pattern) =>
      checkIfTagsContainsTagExpression(tags, pattern);
}

extension PostsX on List<Post> {
  Map<String, int> extractTagsWithoutCount() {
    final tagCounts = <String, int>{};

    for (final item in this) {
      for (final tag in item.tags) {
        if (tagCounts.containsKey(tag)) {
          tagCounts[tag] = tagCounts[tag]! + 1;
        } else {
          tagCounts[tag] = 1;
        }
      }
    }

    return tagCounts;
  }

  Map<String, int> countTagPattern(Iterable<String> patterns) {
    final tagCounts = <String, int>{
      for (final pattern in patterns) pattern: 0,
    };

    for (final item in this) {
      for (final pattern in patterns) {
        if (item.containsTagPattern(pattern)) {
          tagCounts[pattern] = tagCounts[pattern]! + 1;
        }
      }
    }

    return tagCounts;
  }
}

bool checkIfTagsContainsTagExpression(List<String> tags, String tagExpression) {
  var expressions = tagExpression.split(' ');

  var andTags = expressions
      .where((s) => !s.startsWith('-') && !s.startsWith('~'))
      .toList();
  var notTags = expressions
      .where((s) => s.startsWith('-'))
      .map((s) => s.substring(1))
      .toList();
  var orTags = expressions
      .where((s) => s.startsWith('~'))
      .map((s) => s.substring(1))
      .toList();

  // AND logic
  if (andTags.any((tag) => !tags.contains(tag))) return false;

  // NOT logic
  if (notTags.any((tag) => tags.contains(tag))) return false;

  // OR logic
  if (orTags.isNotEmpty && !orTags.any((tag) => tags.contains(tag))) {
    return false;
  }

  return true;
}
