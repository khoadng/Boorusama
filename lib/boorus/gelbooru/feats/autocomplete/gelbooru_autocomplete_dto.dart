class GelbooruAutocompleteDto {
  GelbooruAutocompleteDto({
    required this.type,
    required this.label,
    required this.value,
    required this.postCount,
    required this.category,
  });

  factory GelbooruAutocompleteDto.fromJson(Map<String, dynamic> json) {
    return GelbooruAutocompleteDto(
      type: json['type'],
      label: json['label'],
      value: json['value'],
      postCount: int.tryParse(json['post_count']),
      category: json['category'],
    );
  }

  final String? type;
  final String? label;
  final String? value;
  final int? postCount;
  final String? category;
}
