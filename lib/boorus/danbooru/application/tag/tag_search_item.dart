// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/application/tag/tag.dart';
import 'package:boorusama/boorus/danbooru/infra/services/tag_info_service.dart';
import 'package:boorusama/common/string_utils.dart';

bool _hasMetatag(String query) => query.contains(':');

@immutable
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

    if (!_hasMetatag(query)) {
      return TagSearchItem(
        tag: stripFilterOperator(query, operator).replaceAll('_', ' '),
        operator: operator,
      );
    }

    final metatag = _getMetatagFromString(query, operator);
    final tag = stripFilterOperator(query, operator)
        .replaceAll('$metatag:', '')
        .replaceAll('_', ' ');

    final isValidMetatag = tagInfo.metatags.contains(metatag);

    return TagSearchItem(
      tag: isValidMetatag ? tag : '$metatag:$tag',
      operator: operator,
      metatag: isValidMetatag ? metatag : null,
    );
  }

  final String tag;
  final FilterOperator operator;
  final String? metatag;

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
