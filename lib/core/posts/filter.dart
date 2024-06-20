// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/string.dart';

List<T> filterTags<T extends Post>(List<T> posts, Set<String> tags) =>
    filter(posts, tags, precomputedFilter: {}).data;

({List<T> data, List<T> filtered}) filter<T extends Post>(
  Iterable<T> posts,
  Set<String> blacklistedTags, {
  required Map<int, bool> precomputedFilter,
}) {
  final filtered = <T>[];
  final nonFiltered = <T>[];
  final preprocessedBlacklist = blacklistedTags
      .map((tag) => tag.split(' ').map(TagExpression.parse).toList());

  for (final post in posts) {
    // Check precomputed filter if there is a post Id, it means it has been checked before, so we can use the result instead of rechecking
    if (precomputedFilter.containsKey(post.id)) {
      if (precomputedFilter[post.id]!) {
        filtered.add(post);
      } else {
        nonFiltered.add(post);
      }
      continue;
    }

    var found = false;
    for (final tag in preprocessedBlacklist) {
      if (post.containsTagPattern(tag)) {
        found = true;
        break;
      }
    }
    if (found) {
      filtered.add(post);
      precomputedFilter[post.id] = true;
    } else {
      nonFiltered.add(post);
      precomputedFilter[post.id] = false;
    }
  }

  return (data: nonFiltered, filtered: filtered);
}

extension TagFilterDataX on Set<String> {
  TagFilterData toTagFilterData() => TagFilterData.tags(tags: this);
}

class TagFilterData {
  TagFilterData({
    required this.tags,
    required this.rating,
    required this.score,
    this.downvotes,
    this.uploaderId,
    this.source,
    this.id,
  });

  TagFilterData.tags({
    required this.tags,
  })  : rating = Rating.general,
        score = 0,
        source = null,
        uploaderId = null,
        id = null,
        downvotes = null;

  final Set<String> tags;
  final Rating rating;
  final int score;
  final int? downvotes;
  final int? uploaderId;
  final String? source;
  final int? id;
}

class TagExpression extends Equatable {
  const TagExpression({
    required this.expression,
    required this.isNegative,
    required this.isOr,
    required this.type,
  });

  factory TagExpression.parse(String expression) {
    final isNegative = expression.startsWith('-');
    final isOr = expression.startsWith('~');
    final hasOperator = isNegative || isOr;
    final value = expression.substring(hasOperator ? 1 : 0);
    final type = _getType(value);
    return TagExpression(
      expression: value,
      isNegative: isNegative,
      isOr: isOr,
      type: type,
    );
  }

  String get rawString {
    final operator = switch ((
      isNegative,
      isOr,
    )) {
      (true, false) => '-',
      (false, true) => '~',
      _ => '',
    };

    return '$operator$expression';
  }

  final String expression;
  final bool isNegative;
  final bool isOr;
  final TagExpressionType type;

  @override
  String toString() => expression;

  @override
  List<Object?> get props => [expression, isNegative, type];
}

extension TagExpressionX on Iterable<TagExpression> {
  String get rawString => map((e) => e.rawString).join(' ');
}

TagExpressionType _getType(String expression) {
  final exp = expression.toLowerCase();

  if (exp.startsWith('rating:')) {
    final targetRating = mapStringToRating(exp.split(':')[1].toLowerCase());
    return RatingType(exp, targetRating);
  } else if (exp.startsWith('uploaderid:')) {
    final uploaderId = int.tryParse(exp.split(':')[1]) ?? -1;
    return UploaderIdType(exp, uploaderId);
  } else if (exp.startsWith('source:')) {
    final firstColonIndex = exp.indexOf(':');

    // if first colon is the last character, then the expression is invalid
    if (firstColonIndex == exp.length - 1) return TagType(exp);

    final targetSource = exp.substring(firstColonIndex + 1).toLowerCase();

    // *aaa* is a wildcard for any string
    // *aaa is a wildcard for any string that ends with "aaa"
    // aaa* is a wildcard for any string that starts with "aaa"
    // aaa is a exact match
    final position = switch ((
      targetSource.getFirstCharacter(),
      targetSource.getLastCharacter()
    )) {
      ('*', '*') => WildCardPosition.both,
      ('*', _) => WildCardPosition.start,
      (_, '*') => WildCardPosition.end,
      _ => WildCardPosition.none,
    };

    final source = switch (position) {
      WildCardPosition.both =>
        targetSource.substring(1, targetSource.length - 1),
      WildCardPosition.start => targetSource.substring(1),
      WildCardPosition.end =>
        targetSource.substring(0, targetSource.length - 1),
      WildCardPosition.none => targetSource,
    };

    return SourceType(exp, source, position);
  } else if (exp.startsWith('score:') && exp.contains('<')) {
    final score = int.tryParse(exp.split('<')[1]) ?? 0;

    return ScoreType(exp, score);
  } else if (exp.startsWith('downvotes:') && exp.contains('>')) {
    final downvotes = int.tryParse(exp.split('>')[1]) ?? 0;
    return DownvotesType(exp, downvotes);
  } else {
    return TagType(exp);
  }
}

sealed class TagExpressionType {
  const TagExpressionType(this.value);
  final String value;
}

final class TagType extends TagExpressionType {
  const TagType(super.value);
}

final class RatingType extends TagExpressionType {
  const RatingType(super.value, this.rating);

  final Rating rating;
}

final class UploaderIdType extends TagExpressionType {
  const UploaderIdType(super.value, this.uploaderId);

  final int uploaderId;
}

final class SourceType extends TagExpressionType {
  const SourceType(
    super.value,
    this.source,
    this.wildCardPosition,
  );

  final String source;
  final WildCardPosition wildCardPosition;
}

final class ScoreType extends TagExpressionType {
  const ScoreType(super.value, this.score);

  final int score;
}

final class DownvotesType extends TagExpressionType {
  const DownvotesType(super.value, this.downvotes);

  final int downvotes;
}

enum WildCardPosition {
  start,
  end,
  both,
  none,
}

bool checkIfTagsContainsRawTagExpression(
  final TagFilterData filterData,
  final String tagExpression, {
  bool caseSensitive = false,
}) {
  // Split the tagExpression by spaces to handle multiple tags
  final expressions =
      tagExpression.split(' ').map(TagExpression.parse).toList();

  return checkIfTagsContainsTagExpression(
    filterData,
    expressions,
    caseSensitive: caseSensitive,
  );
}

bool checkIfTagsContainsTagExpression(
  final TagFilterData filterData,
  final List<TagExpression> expressions, {
  bool caseSensitive = false,
}) {
  final tags = caseSensitive
      ? filterData.tags
      : filterData.tags.map((tag) => tag.toLowerCase()).toSet();

  // Process each tag in the expression
  for (final expression in expressions) {
    final type = expression.type;
    final isNegative = expression.isNegative;
    final isOr = expression.isOr;
    final value = caseSensitive
        ? expression.expression
        : expression.expression.toLowerCase();

    // Handle metatag "rating"
    if (type is RatingType && !isNegative) {
      if (filterData.rating != type.rating) {
        return false;
      }
    }
    // Handle uploaderid "uploaderid"
    else if (type is UploaderIdType) {
      if (filterData.uploaderId != type.uploaderId) {
        return false;
      }
    }
    // Handle source "source"
    else if (type is SourceType && filterData.source != null) {
      // find the first index of ':' and get the substring after it
      final source = filterData.source!.toLowerCase();
      final targetSource = type.source;
      final wildCardPosition = type.wildCardPosition;

      if (wildCardPosition == WildCardPosition.both) {
        if (!source.contains(targetSource)) {
          return false;
        }
      } else if (wildCardPosition == WildCardPosition.start) {
        if (!source.endsWith(targetSource)) {
          return false;
        }
      } else if (wildCardPosition == WildCardPosition.end) {
        if (!source.startsWith(targetSource)) {
          return false;
        }
      } else if (filterData.source != targetSource) {
        return false;
      }
    }
    // Handle NOT operator with metatag "rating"
    else if (type is RatingType && isNegative) {
      if (filterData.rating == type.rating) {
        return false;
      }
    }
    // Handle metatag "score"
    else if (type is ScoreType) {
      if (!(filterData.score < type.score)) {
        return false;
      }
      // Handle metatag "downvotes"
    } else if (type is DownvotesType) {
      if (filterData.downvotes == null ||
          !(filterData.downvotes! > type.downvotes)) {
        return false;
      }
    }
    // Handle NOT operator
    else if (isNegative) {
      if (tags.contains(value)) {
        return false;
      }
    }
    // Default AND operation
    else if (!tags.contains(value) && !isOr) {
      return false;
    }
  }

  // OR operation check
  if (expressions.any((exp) => exp.isOr) &&
      !expressions
          .where((exp) => exp.isOr)
          .any((orExp) => tags.contains(orExp.expression))) {
    return false;
  }

  return true; // If all checks pass, return true
}
