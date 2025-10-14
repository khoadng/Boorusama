// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../search/queries/types.dart';
import 'metatag.dart';

class DefaultMetatagExtractor implements MetatagExtractor {
  const DefaultMetatagExtractor({
    required this.metatags,
  });

  final Set<Metatag>? metatags;

  @override
  String? fromString(
    String str,
  ) {
    if (!hasMetatag(str)) return null;

    final operator = FilterOperator.fromString(str.getFirstCharacter());

    final query = str.split(':');
    if (query.length <= 1) return null;
    if (query.first.isEmpty) return null;

    return stripFilterOperator(query.first, operator);
  }

  @override
  bool hasMetatag(String query) =>
      metatags?.toList().any((tag) => query.startsWith('${tag.name}:')) ??
      false;
}
