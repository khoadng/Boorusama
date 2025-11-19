// Package imports:
import 'package:equatable/equatable.dart';

class SortableTagType extends Equatable {
  const SortableTagType({
    required this.name,
  });

  final String name;

  @override
  List<Object?> get props => [name];

  static bool isValidSortMetatag(
    String query,
    Set<SortableTagType> sortableTypes,
  ) => switch (query.split(':')) {
    ['sort', final type, final order]
        when sortableTypes.any((t) => t.name == type) &&
            SortType.isValid(order) =>
      true,
    _ => false,
  };
}

enum SortType {
  ascending,
  descending;

  factory SortType.fromString(String value) => switch (value.toLowerCase()) {
    'asc' || 'ascending' => SortType.ascending,
    'desc' || 'descending' => SortType.descending,
    _ => SortType.ascending,
  };

  String toShortString() => switch (this) {
    ascending => 'asc',
    descending => 'desc',
  };

  static bool isValid(String value) {
    final validValues = SortType.values.map((e) => e.toShortString()).toSet();
    return validValues.contains(value);
  }
}

String buildMetatagRegexPattern({
  required List<String> metatags,
  required List<String> sortableTypes,
}) {
  final regularMetatags = metatags.where((e) => e != 'sort').join('|');
  final sortablePattern = sortableTypes.join('|');

  return 'sort:(?:(?:$sortablePattern)(?::(?:asc|desc)?)?)?|(?:$regularMetatags):';
}

String? extractMetatagMatch(
  String input,
  List<String> metatags,
  List<String> sortableTypes,
) {
  final pattern = buildMetatagRegexPattern(
    metatags: metatags,
    sortableTypes: sortableTypes,
  );
  final regex = RegExp(pattern, caseSensitive: false);
  final match = regex.firstMatch(input);

  return (match != null && match.start == 0) ? match.group(0) : null;
}
