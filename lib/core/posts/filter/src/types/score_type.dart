// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class ScoreTypeParser implements TagExpressionTypeParser {
  const ScoreTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'score';

  @override
  TagExpressionType parse(String exp, String value) {
    final lessThanIndex = value.indexOf('<');
    if (lessThanIndex == -1) return TagType(exp);

    return ScoreType(
      exp,
      int.tryParse(value.substring(lessThanIndex + 1)) ?? 0,
    );
  }
}

final class ScoreType extends TagExpressionType {
  const ScoreType(super.value, this.score);

  final int score;

  @override
  bool evaluate(TagFilterData filterData) => filterData.score < score;
}
