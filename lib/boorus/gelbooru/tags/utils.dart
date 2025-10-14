// Package imports:
import 'package:dio/dio.dart';

// Project imports:
import '../../../core/tags/categories/types.dart';
import '../../../core/tags/tag/types.dart';

final invalidTags = [
  ':&lt;',
];

Future<List<Tag>> resolveGelbooruRawTags(
  Iterable<String> rawTags,
  TagResolver tagResolver, {
  CancelToken? cancelToken,
}) async {
  // filter tagList to remove invalid tags
  final filtered = rawTags.where((e) => !invalidTags.contains(e)).toSet();

  if (filtered.isEmpty) return const [];

  final tags = await tagResolver.resolveRawTags(
    filtered,
    cancelToken: cancelToken,
  );

  return tags;
}

TagCategory stringToGelbooruTagCategory(String? type) => switch (type) {
  '6' || 'deprecated' => gelbooruDeprecatedTagCategory,
  final type => TagCategory.fromLegacyIdString(type),
};

const gelbooruDeprecatedTagCategory = TagCategory(
  id: 6,
  order: 6,
  name: 'deprecated',
  originalName: 'deprecated',
);
