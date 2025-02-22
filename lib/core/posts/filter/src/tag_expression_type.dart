// Project imports:
import 'tag_filter_data.dart';

abstract interface class TagExpressionTypeParser {
  /// Returns true if this parser can handle the given prefix.
  bool canParse(String prefix);

  /// Parses the given expression into a TagExpressionType.
  TagExpressionType parse(String exp, String value);
}

abstract class TagExpressionType {
  const TagExpressionType(this.value);
  final String value;

  /// Returns true if the [filterData] satisfies this expression.
  bool evaluate(TagFilterData filterData);
}

final class TagType extends TagExpressionType {
  const TagType(super.value);

  @override
  bool evaluate(TagFilterData filterData) => filterData.tags.contains(value);
}
