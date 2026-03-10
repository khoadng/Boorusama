class AutocompleteDto {
  AutocompleteDto({
    this.tagId,
    this.title,
    this.desc,
    this.type,
    this.dateAdded,
    this.aliasOf,
    this.aliasOfName,
    this.isAlias,
    this.usageCount,
  });

  final int? tagId;
  final String? title;
  final String? desc;
  final int? type;
  final DateTime? dateAdded;
  final int? aliasOf;
  final String? aliasOfName;
  final bool? isAlias;
  final int? usageCount;

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) {
    return AutocompleteDto(
      tagId: json['tag_id'] as int?,
      title: json['title'] as String?,
      desc: json['desc'] as String?,
      type: json['type'] as int?,
      dateAdded: _parseDate(json['date_added'] as String?),
      aliasOf: json['alias_of'] as int?,
      aliasOfName: json['alias_of_name'] as String?,
      isAlias: json['is_alias'] as bool?,
      usageCount: json['usage_count'] as int?,
    );
  }

  @override
  String toString() => title ?? '';
}

DateTime? _parseDate(String? dateString) {
  if (dateString == null) return null;
  return DateTime.tryParse(dateString);
}

List<AutocompleteDto> parseAutocompleteFromApi(dynamic data) => switch (data) {
  {'tags': final List tags} =>
    tags
        .whereType<Map<String, dynamic>>()
        .map(AutocompleteDto.fromJson)
        .toList(),
  _ => [],
};
