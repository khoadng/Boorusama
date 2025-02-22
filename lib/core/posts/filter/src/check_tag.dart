// Project imports:
import 'tag_expression.dart';
import 'tag_filter_data.dart';

bool checkIfTagsContainsRawTagExpression(
  final TagFilterData filterData,
  final String tagExpression,
) {
  // Split the tagExpression by spaces to handle multiple tags
  final expressions =
      tagExpression.split(' ').map(TagExpression.parse).toList();

  return checkIfTagsContainsTagExpression(
    filterData,
    expressions,
  );
}

bool checkIfTagsContainsTagExpression(
  final TagFilterData filterData,
  final List<TagExpression> expressions,
) {
  // Separate AND and OR expressions.
  final andExpressions = expressions.where((e) => !e.isOr).toList();
  final orExpressions = expressions.where((e) => e.isOr).toList();

  // Check all AND expressions.
  for (final exp in andExpressions) {
    final result = exp.type.evaluate(filterData);
    if (exp.isNegative) {
      if (result) {
        return false;
      }
    } else {
      if (!result) {
        return false;
      }
    }
  }

  // For any OR expressions, at least one must be satisfied if any exist.
  if (orExpressions.isNotEmpty) {
    final orSatisfied = orExpressions.any((exp) {
      final result = exp.type.evaluate(filterData);
      return exp.isNegative ? !result : result;
    });
    if (!orSatisfied) {
      return false;
    }
  }

  return true;
}
