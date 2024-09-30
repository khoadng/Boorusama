// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/string.dart';
import 'filter_operator.dart';

class TagSearchItem extends Equatable {
  const TagSearchItem({
    required this.tag,
    required this.operator,
    required this.originalTag,
    this.metatag,
    this.isRaw = false,
  });

  const TagSearchItem.raw({
    required this.tag,
  })  : operator = FilterOperator.none,
        isRaw = true,
        originalTag = tag,
        metatag = null;

  factory TagSearchItem.fromString(
    String query,
    MetatagExtractor? extractor,
  ) {
    final metatag = extractor?.fromString(query);
    final operator = stringToFilterOperator(query.getFirstCharacter());
    final tag = stripFilterOperator(query, operator);

    if (metatag == null) {
      return TagSearchItem(
        tag: tag.replaceUnderscoreWithSpace(),
        operator: operator,
        originalTag: query,
      );
    }

    return TagSearchItem(
      tag: tag.replaceAll('$metatag:', '').replaceUnderscoreWithSpace(),
      operator: operator,
      metatag: metatag,
      originalTag: query,
    );
  }

  final String originalTag;
  final String tag;
  final FilterOperator operator;
  final String? metatag;
  final bool isRaw;

  // This assume no whitespace in the tag, which is true for most boorus
  String get rawTag => tag.replaceAll(' ', '_');

  @override
  List<Object?> get props => [tag, operator, metatag, isRaw, originalTag];

  @override
  String toString() => isRaw
      ? tag
      : '${filterOperatorToString(operator)}${metatag ?? ''}${metatag != null ? ':' : ''}$tag'
          .replaceAll(' ', '_');
}
