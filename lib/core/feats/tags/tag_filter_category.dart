// Project imports:
import 'package:boorusama/functional.dart';

enum TagFilterCategory {
  popular,
  newest,
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
