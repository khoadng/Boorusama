// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class UploaderIdTypeParser implements TagExpressionTypeParser {
  const UploaderIdTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'uploaderid';

  @override
  TagExpressionType parse(String exp, String value) =>
      UploaderIdType(exp, int.tryParse(value) ?? -1);
}

final class UploaderIdType extends TagExpressionType {
  const UploaderIdType(super.value, this.uploaderId);

  final int uploaderId;

  @override
  bool evaluate(TagFilterData filterData) =>
      filterData.uploaderId != null && filterData.uploaderId == uploaderId;
}
