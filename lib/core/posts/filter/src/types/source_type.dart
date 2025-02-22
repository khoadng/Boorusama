// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class SourceTypeParser implements TagExpressionTypeParser {
  const SourceTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'source';

  @override
  TagExpressionType parse(String exp, String value) {
    if (value.isEmpty) return TagType(exp);
    final firstChar = value[0];
    final lastChar = value[value.length - 1];

    final position = switch ((firstChar, lastChar)) {
      ('*', '*') => WildCardPosition.both,
      ('*', _) => WildCardPosition.start,
      (_, '*') => WildCardPosition.end,
      _ => WildCardPosition.none,
    };
    final src = switch (position) {
      WildCardPosition.both => value.substring(1, value.length - 1),
      WildCardPosition.start => value.substring(1),
      WildCardPosition.end => value.substring(0, value.length - 1),
      WildCardPosition.none => value,
    };
    return SourceType(exp, src.toLowerCase(), position);
  }
}

final class SourceType extends TagExpressionType {
  const SourceType(
    super.value,
    this.source,
    this.wildCardPosition,
  );

  final String source;
  final WildCardPosition wildCardPosition;

  @override
  bool evaluate(TagFilterData filterData) {
    final fileSource = filterData.source;
    if (fileSource == null) return false;

    return switch (wildCardPosition) {
      WildCardPosition.both => fileSource.contains(source),
      WildCardPosition.start => fileSource.endsWith(source),
      WildCardPosition.end => fileSource.startsWith(source),
      WildCardPosition.none => fileSource == source,
    };
  }
}

enum WildCardPosition { start, end, both, none }
