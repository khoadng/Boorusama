// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/core/search/search.dart';
import 'package:boorusama/string.dart';

class Metatag extends Equatable {
  const Metatag({
    required this.name,
    required this.description,
    required this.example,
    this.isFree = false,
  });

  const Metatag.simple({
    required this.name,
    this.isFree = false,
  })  : description = '',
        example = '';

  final String name;
  final String description;
  final String example;
  final bool isFree;

  @override
  List<Object?> get props => [name, description, example, isFree];
}

class MetatagExtractor {
  const MetatagExtractor({
    required this.metatags,
  });

  final Set<Metatag>? metatags;

  String? fromString(
    String str,
  ) {
    if (!hasMetatag(str)) return null;

    final operator = stringToFilterOperator(str.getFirstCharacter());

    final query = str.split(':');
    if (query.length <= 1) return null;
    if (query.first.isEmpty) return null;

    return stripFilterOperator(query.first, operator);
  }

  bool hasMetatag(String query) =>
      metatags?.toList().any((tag) => query.startsWith('${tag.name}:')) ??
      false;
}
