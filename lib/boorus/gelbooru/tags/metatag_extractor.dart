// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/search/queries/types.dart';
import '../../../core/tags/metatag/types.dart';
import 'types.dart';

class GelbooruMetatagExtractor implements MetatagExtractor {
  const GelbooruMetatagExtractor({
    required this.metatags,
    required this.sortableTypes,
  });

  final Set<Metatag>? metatags;
  final Set<SortableTagType> sortableTypes;

  @override
  String? fromString(
    String str,
  ) {
    if (!hasMetatag(str)) return null;

    final operator = FilterOperator.fromString(str.getFirstCharacter());
    final strippedStr = stripFilterOperator(str, operator);

    // Find which metatag this string starts with
    final metatagName = metatags
        ?.toList()
        .firstWhere(
          (tag) => strippedStr.startsWith('${tag.name}:'),
          orElse: () => const Metatag.simple(name: ''),
        )
        .name;

    if (metatagName == null || metatagName.isEmpty) return null;

    return metatagName;
  }

  @override
  bool hasMetatag(String query) {
    final operator = FilterOperator.fromString(query.getFirstCharacter());
    final strippedQuery = stripFilterOperator(query, operator);

    // Special validation for sort metatag
    if (strippedQuery.startsWith('sort:')) {
      return SortableTagType.isValidSortMetatag(strippedQuery, sortableTypes);
    }

    return metatags?.toList().any(
          (tag) => strippedQuery.startsWith('${tag.name}:'),
        ) ??
        false;
  }
}
