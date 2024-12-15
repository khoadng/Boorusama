// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../rating/rating.dart';
import 'tag_expression_type.dart';

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
    final value = expression.substring(hasOperator ? 1 : 0).toLowerCase();
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
  final exp = expression;
  final colonIndex = exp.indexOf(':');

  // Early return if no colon
  if (colonIndex == -1) return TagType(exp);

  final prefix = exp.substring(0, colonIndex);
  final value =
      colonIndex < exp.length - 1 ? exp.substring(colonIndex + 1) : '';

  switch (prefix) {
    case 'rating':
      return RatingType(exp, mapStringToRating(value));

    case 'uploaderid':
      return UploaderIdType(exp, int.tryParse(value) ?? -1);

    case 'source':
      if (value.isEmpty) return TagType(exp);

      final firstChar = value.getFirstCharacter();
      final lastChar = value.getLastCharacter();

      // *aaa* is a wildcard for any string
      // *aaa is a wildcard for any string that ends with "aaa"
      // aaa* is a wildcard for any string that starts with "aaa"
      // aaa is a exact match
      final position = switch ((firstChar, lastChar)) {
        ('*', '*') => WildCardPosition.both,
        ('*', _) => WildCardPosition.start,
        (_, '*') => WildCardPosition.end,
        _ => WildCardPosition.none,
      };

      final source = switch (position) {
        WildCardPosition.both => value.substring(1, value.length - 1),
        WildCardPosition.start => value.substring(1),
        WildCardPosition.end => value.substring(0, value.length - 1),
        WildCardPosition.none => value,
      };

      return SourceType(exp, source.toLowerCase(), position);

    case 'score':
      final lessThanIndex = value.indexOf('<');
      if (lessThanIndex == -1) return TagType(exp);
      return ScoreType(
        exp,
        int.tryParse(value.substring(lessThanIndex + 1)) ?? 0,
      );

    case 'downvotes':
      final greaterThanIndex = value.indexOf('>');
      if (greaterThanIndex == -1) return TagType(exp);
      return DownvotesType(
        exp,
        int.tryParse(value.substring(greaterThanIndex + 1)) ?? 0,
      );

    default:
      return TagType(exp);
  }
}
