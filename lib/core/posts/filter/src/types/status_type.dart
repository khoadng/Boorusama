// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class StatusTypeParser implements TagExpressionTypeParser {
  const StatusTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'status';

  @override
  TagExpressionType parse(String exp, String value) => StatusType(exp, value);
}

class StatusType extends TagExpressionType {
  const StatusType(super.value, this.status);

  final String status;

  @override
  bool evaluate(TagFilterData filterData) {
    return switch (filterData.status) {
      null => false,
      final postStatus => postStatus.matches(status),
    };
  }
}
