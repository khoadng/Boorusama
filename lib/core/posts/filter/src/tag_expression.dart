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
