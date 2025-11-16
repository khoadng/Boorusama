// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'tag_expression_type.dart';
import 'types/downvotes_type.dart';
import 'types/rating_type.dart';
import 'types/score_type.dart';
import 'types/source_type.dart';
import 'types/status_type.dart';
import 'types/uploader_id_type.dart';
import 'types/uploader_type.dart';

const kDefaultTagParser = TagExpressionParser(
  parsers: [
    RatingTypeParser(),
    UploaderIdTypeParser(),
    UploaderTypeParser(),
    SourceTypeParser(),
    ScoreTypeParser(),
    DownvotesTypeParser(),
    StatusTypeParser(),
  ],
);

class TagExpressionParser {
  const TagExpressionParser({
    required List<TagExpressionTypeParser> parsers,
  }) : _parsers = parsers;

  final List<TagExpressionTypeParser> _parsers;

  TagExpression parse(String expression) {
    final isNegative = expression.startsWith('-');
    final isOr = expression.startsWith('~');
    final hasOperator = isNegative || isOr;
    final value = expression.substring(hasOperator ? 1 : 0).toLowerCase();
    final type = _parseType(value);

    return TagExpression(
      expression: value,
      isNegative: isNegative,
      isOr: isOr,
      type: type,
    );
  }

  TagExpressionType _parseType(String exp) {
    final colonIndex = exp.indexOf(':');
    if (colonIndex == -1 || colonIndex == exp.length - 1) return TagType(exp);

    final prefix = exp.substring(0, colonIndex);
    final value = exp.substring(colonIndex + 1);

    for (final parser in _parsers) {
      if (parser.canParse(prefix)) {
        return parser.parse(exp, value);
      }
    }
    return TagType(exp);
  }
}

class TagExpression extends Equatable {
  const TagExpression({
    required this.expression,
    required this.isNegative,
    required this.isOr,
    required this.type,
  });

  factory TagExpression.parse(
    String expression, {
    TagExpressionParser parser = kDefaultTagParser,
  }) => parser.parse(expression);

  String get rawString {
    final operator = switch ((isNegative, isOr)) {
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
