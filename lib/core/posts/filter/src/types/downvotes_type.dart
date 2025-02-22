// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class DownvotesTypeParser implements TagExpressionTypeParser {
  const DownvotesTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'downvotes';

  @override
  TagExpressionType parse(String exp, String value) {
    final greaterThanIndex = value.indexOf('>');
    if (greaterThanIndex == -1) return TagType(exp);

    return DownvotesType(
      exp,
      int.tryParse(value.substring(greaterThanIndex + 1)) ?? 0,
    );
  }
}

final class DownvotesType extends TagExpressionType {
  const DownvotesType(super.value, this.downvotes);

  final int downvotes;

  @override
  bool evaluate(TagFilterData filterData) =>
      filterData.downvotes != null && filterData.downvotes! > downvotes;
}
