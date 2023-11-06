// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/foundation/video.dart';

abstract class Post extends Equatable
    with MediaInfoMixin, ImageInfoMixin, VideoInfoMixin, TagListCheckMixin
    implements TagDetails {
  int get id;
  DateTime? get createdAt;
  String get thumbnailImageUrl;
  String get sampleImageUrl;
  String get originalImageUrl;
  @override
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

abstract interface class TagDetails {
  List<String>? get artistTags;
  List<String>? get characterTags;
  List<String>? get copyrightTags;
}

class SimplePost extends Equatable
    with
        MediaInfoMixin,
        TranslatedMixin,
        ImageInfoMixin,
        VideoInfoMixin,
        NoTagDetailsMixin,
        TagListCheckMixin
    implements Post {
  SimplePost({
    required this.id,
    this.createdAt,
    required this.thumbnailImageUrl,
    required this.sampleImageUrl,
    required this.originalImageUrl,
    required this.tags,
    required this.rating,
    required this.hasComment,
    required this.isTranslated,
    required this.hasParentOrChildren,
    this.parentId,
    required this.source,
    required this.score,
    this.downvotes,
    required this.duration,
    required this.fileSize,
    required this.format,
    required this.hasSound,
    required this.height,
    required this.md5,
    required this.videoThumbnailUrl,
    required this.videoUrl,
    required this.width,
    required Function(String baseUrl) getLink,
  }) : _getLink = getLink;

  @override
  final int id;
  @override
  final DateTime? createdAt;
  @override
  final String thumbnailImageUrl;
  @override
  final String sampleImageUrl;
  @override
  final String originalImageUrl;
  @override
  final List<String> tags;
  @override
  final Rating rating;
  @override
  final bool hasComment;
  @override
  final bool isTranslated;
  @override
  final bool hasParentOrChildren;
  @override
  final int? parentId;
  @override
  final PostSource source;
  @override
  final int score;
  @override
  final int? downvotes;
  @override
  final double duration;
  @override
  final int fileSize;
  @override
  final String format;
  @override
  final bool? hasSound;
  @override
  final double height;
  @override
  final String md5;
  @override
  final String videoThumbnailUrl;
  @override
  final String videoUrl;
  @override
  final double width;

  final Function(String baseUrl) _getLink;

  @override
  String getLink(String baseUrl) => _getLink(baseUrl);

  @override
  Uri getUriLink(String baseUrl) => Uri.parse(getLink(baseUrl));

  @override
  List<Object?> get props => [id];
}

mixin NoTagDetailsMixin implements Post {
  @override
  List<String>? get artistTags => null;
  @override
  List<String>? get characterTags => null;
  @override
  List<String>? get copyrightTags => null;
}

extension PostImageX on Post {
  bool get hasFullView => originalImageUrl.isNotEmpty && !isVideo;

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
}

mixin TagListCheckMixin {
  List<String> get tags;

  bool get isAI => tags.any((e) => _kAiTags.contains(e.toLowerCase()));
}

const _kAiTags = {
  'ai-generated',
  'ai_generated',
  'ai-created',
  'ai art',
};

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
