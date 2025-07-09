// Package imports:
import 'package:equatable/equatable.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../tags/metatag/metatag.dart';
import '../queries/filter_operator.dart';

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
  }) : operator = FilterOperator.none,
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
        tag: tag.replaceAll('_', ' '),
        operator: operator,
        originalTag: query,
      );
    }

    return TagSearchItem(
      tag: tag.replaceAll('$metatag:', '').replaceAll('_', ' '),
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
