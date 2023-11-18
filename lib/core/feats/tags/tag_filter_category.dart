// Project imports:
import 'package:boorusama/functional.dart';

enum TagFilterCategory {
  newest,
  popular,
}

typedef TagFilterCategoryStringBuilder = Option<String> Function(
    TagFilterCategory category);

List<String> queryFromTagFilterCategory({
  required TagFilterCategory category,
  required TagFilterCategoryStringBuilder builder,
  required String tag,
}) =>
    builder(category).fold(
      () => [tag],
      (query) => [tag, query],
    );
