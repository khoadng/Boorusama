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
  int? get parentId;
  PostSource get source;
  int get score;
  int? get downvotes;

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

  bool containsTagPattern(String pattern) => checkIfTagsContainsTagExpression(
      TagFilterData(
        tags: tags,
        rating: rating,
        score: score,
        downvotes: downvotes,
      ),
      pattern);

  bool get isAI =>
      tags.contains('ai-generated') || tags.contains('ai_generated');
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

extension TagFilterDataX on List<String> {
  TagFilterData toTagFilterData() => TagFilterData.tags(tags: this);
}

class TagFilterData {
  TagFilterData({
    required this.tags,
    required this.rating,
    required this.score,
    this.downvotes,
  });

  TagFilterData.tags({
    required this.tags,
  })  : rating = Rating.general,
        score = 0,
        downvotes = null;

  final List<String> tags;
  final Rating rating;
  final int score;
  final int? downvotes;
}

bool checkIfTagsContainsTagExpression(
  final TagFilterData filterData,
  final String tagExpression,
) {
  // Split the tagExpression by spaces to handle multiple tags
  final expressions = tagExpression.split(' ');

  // Process each tag in the expression
  for (final expression in expressions) {
    // Handle metatag "rating"
    if (expression.startsWith('rating:')) {
      final targetRating =
          expression.endsWith('explicit') ? Rating.explicit : Rating.general;
      if (filterData.rating != targetRating) {
        return false;
      }
    }
    // Handle NOT operator with metatag "rating"
    else if (expression.startsWith('-rating:')) {
      final targetRating =
          expression.endsWith('explicit') ? Rating.explicit : Rating.general;
      if (filterData.rating == targetRating) {
        return false;
      }
    }
    // Handle metatag "score"
    else if (expression.startsWith('score:') && expression.contains('<')) {
      final targetScore = int.tryParse(expression.split('<')[1]) ?? 0;
      if (!(filterData.score < targetScore)) {
        return false;
      }
      // Handle metatag "downvotes"
    } else if (expression.startsWith('downvotes:') &&
        expression.contains('>')) {
      final targetDownvotes = int.tryParse(expression.split('>')[1]) ?? 0;
      if (filterData.downvotes == null ||
          !(filterData.downvotes! > targetDownvotes)) {
        return false;
      }
    }
    // Handle NOT operator
    else if (expression.startsWith('-')) {
      if (filterData.tags.contains(expression.substring(1))) {
        return false;
      }
    }
    // Default AND operation
    else if (!filterData.tags.contains(expression) &&
        !expression.startsWith('~')) {
      return false;
    }
  }

  // OR operation check
  if (expressions.any((exp) => exp.startsWith('~')) &&
      !expressions
          .where((exp) => exp.startsWith('~'))
          .any((orExp) => filterData.tags.contains(orExp.substring(1)))) {
    return false;
  }

  return true; // If all checks pass, return true
}
