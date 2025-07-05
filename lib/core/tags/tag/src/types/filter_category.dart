// Package imports:
import 'package:foundation/foundation.dart';

enum TagFilterCategory {
  newest,
  popular,
}

typedef TagFilterCategoryStringBuilder = Option<String> Function(
  TagFilterCategory category,
);

String queryFromTagFilterCategory({
  required TagFilterCategory category,
  required TagFilterCategoryStringBuilder builder,
  required String tag,
}) =>
    builder(category).fold(
      () => tag,
      (query) => [tag, query].join(' '),
    );
