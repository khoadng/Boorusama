// Project imports:
import '../tag_expression_type.dart';
import '../tag_filter_data.dart';

class UploaderTypeParser implements TagExpressionTypeParser {
  const UploaderTypeParser();

  @override
  bool canParse(String prefix) => prefix == 'uploader';

  @override
  TagExpressionType parse(String exp, String value) => UploaderType(exp, value);
}

final class UploaderType extends TagExpressionType {
  const UploaderType(super.value, this.uploaderName);

  final String uploaderName;

  @override
  bool evaluate(TagFilterData filterData) =>
      filterData.uploaderName != null &&
      filterData.uploaderName!.toLowerCase() == uploaderName.toLowerCase();
}
