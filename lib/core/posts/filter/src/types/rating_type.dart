// Project imports:
import '../../../rating/types.dart';
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class RatingTypeParser implements TagExpressionTypeParser {
  const RatingTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'rating';

  @override
  TagExpressionType parse(String exp, String value) =>
      RatingType(exp, mapStringToRating(value));
}

class RatingType extends TagExpressionType {
  const RatingType(super.value, this.rating);

  final Rating rating;

  @override
  bool evaluate(TagFilterData filterData) => filterData.rating == rating;
}
