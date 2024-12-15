// Project imports:
import 'tag_expression.dart';
import 'tag_expression_type.dart';
import 'tag_filter_data.dart';

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
  final source = filterData.source?.toLowerCase();

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
    else if (type is SourceType && source != null) {
      // find the first index of ':' and get the substring after it
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
