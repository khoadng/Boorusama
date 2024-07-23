// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/string.dart';
import 'filter_operator.dart';

bool _hasMetatag(String query, Set<Metatag>? metatags) =>
    metatags?.toList().any((tag) => query.startsWith('${tag.name}:')) ?? false;

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
    Set<Metatag>? metatags,
  ) {
    final operator = stringToFilterOperator(query.getFirstCharacter());

    if (!_hasMetatag(query, metatags)) {
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
        metatags?.map((e) => e.name).contains(metatag) ?? false;

    return TagSearchItem(
      tag: isValidMetatag ? tag : '$metatag:$tag',
      operator: operator,
      metatag: isValidMetatag ? metatag : null,
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

String? _getMetatagFromString(
  String str,
  FilterOperator operator,
) {
  final query = str.split(':');
  if (query.length <= 1) return null;
  if (query.first.isEmpty) return null;

  return stripFilterOperator(query.first, operator);
}
