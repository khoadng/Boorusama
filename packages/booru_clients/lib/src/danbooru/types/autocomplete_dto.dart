class AutocompleteDto {
  AutocompleteDto({
    this.type,
    this.label,
    this.value,
    this.category,
    this.postCount,
    this.antecedent,
    this.level,
  });

  factory AutocompleteDto.fromJson(Map<String, dynamic> json) =>
      AutocompleteDto(
        type: json['type'],
        label: json['label'],
        value: json['value'],
        category: json['category'],
        postCount: json['post_count'],
        antecedent: json['antecedent'],
        level: json['level'],
      );

  final String? type;
  final String? label;
  final String? value;
  final dynamic category;
  final int? postCount;
  final String? antecedent;
  final String? level;

  @override
  String toString() => '${label ?? ''} ($postCount)';
}
