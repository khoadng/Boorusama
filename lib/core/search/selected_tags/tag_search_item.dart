// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../tags/metatag/types.dart';
import '../queries/types.dart';

class TagSearchItem extends Equatable {
  const TagSearchItem._({
    required this.tag,
    required this.operator,
    required this.originalTag,
    required this.isRaw,
    this.metatag,
    this.category,
  });

  const TagSearchItem.raw({
    required this.tag,
  }) : operator = FilterOperator.none,
       isRaw = true,
       originalTag = tag,
       category = null,
       metatag = null;

  factory TagSearchItem.fromString(
    String query, {
    MetatagExtractor? extractor,
    String? category,
  }) {
    final metatag = extractor?.fromString(query);
    final operator = stringToFilterOperator(query.getFirstCharacter());
    final tag = stripFilterOperator(query, operator);

    if (metatag == null) {
      return TagSearchItem._(
        tag: tag.replaceAll('_', ' '),
        operator: operator,
        originalTag: query,
        isRaw: false,
        category: category,
      );
    }

    return TagSearchItem._(
      tag: tag.replaceAll('$metatag:', '').replaceAll('_', ' '),
      operator: operator,
      metatag: metatag,
      originalTag: query,
      isRaw: false,
      category: category,
    );
  }

  final String originalTag;
  final String tag;
  final FilterOperator operator;
  final String? metatag;
  final bool isRaw;
  final String? category;

  // This assume no whitespace in the tag, which is true for most boorus
  String get rawTag => tag.replaceAll(' ', '_');

  @override
  List<Object?> get props => [
    tag,
    operator,
    metatag,
    isRaw,
    originalTag,
    category,
  ];

  @override
  String toString() => isRaw
      ? tag
      : '${filterOperatorToString(operator)}${metatag ?? ''}${metatag != null ? ':' : ''}$tag'
            .replaceAll(' ', '_');
}
