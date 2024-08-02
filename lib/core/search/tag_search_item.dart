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
    this.metatag,
    this.isRaw = false,
  });

  const TagSearchItem.raw({
    required this.tag,
  })  : operator = FilterOperator.none,
        isRaw = true,
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
      );
    }

    return TagSearchItem(
      tag: tag.replaceAll('$metatag:', '').replaceUnderscoreWithSpace(),
      operator: operator,
      metatag: metatag,
    );
  }

  final String tag;
  final FilterOperator operator;
  final String? metatag;
  final bool isRaw;

  String get rawTag => tag.replaceAll(' ', '_');

  @override
  List<Object?> get props => [tag, operator, metatag];

  @override
  String toString() => isRaw
      ? tag
      : '${filterOperatorToString(operator)}${metatag ?? ''}${metatag != null ? ':' : ''}$tag'
          .replaceAll(' ', '_');
}
