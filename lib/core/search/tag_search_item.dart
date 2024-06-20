// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/string.dart';
import 'filter_operator.dart';

bool _hasMetatag(String query, TagInfo tagInfo) =>
    tagInfo.metatags.any((tag) => query.startsWith('${tag.name}:'));

class TagSearchItem extends Equatable {
  const TagSearchItem({
    required this.tag,
    required this.operator,
    this.metatag,
  });

  factory TagSearchItem.fromString(
    String query,
    TagInfo tagInfo,
  ) {
    final operator = stringToFilterOperator(query.getFirstCharacter());

    if (!_hasMetatag(query, tagInfo)) {
      return TagSearchItem(
        tag: stripFilterOperator(query, operator).replaceUnderscoreWithSpace(),
        operator: operator,
      );
    }

    final metatag = _getMetatagFromString(query, operator);
    final tag = stripFilterOperator(query, operator)
        .replaceAll('$metatag:', '')
        .replaceUnderscoreWithSpace();

    final isValidMetatag =
        tagInfo.metatags.map((e) => e.name).contains(metatag);

    return TagSearchItem(
      tag: isValidMetatag ? tag : '$metatag:$tag',
      operator: operator,
      metatag: isValidMetatag ? metatag : null,
    );
  }

  final String tag;
  final FilterOperator operator;
  final String? metatag;

  String get rawTag => tag.replaceAll(' ', '_');

  @override
  List<Object?> get props => [tag, operator, metatag];
  @override
  String toString() =>
      '${filterOperatorToString(operator)}${metatag ?? ''}${metatag != null ? ':' : ''}$tag'
          .replaceAll(' ', '_');
}

String? _getMetatagFromString(
  String str,
  FilterOperator operator,
) {
  final query = str.split(':');
  if (query.length <= 1) return null;
  if (query.first.isEmpty) return null;

  return stripFilterOperator(query.first, operator);
}
