class TagDto {
  final List<String>? names;
  final String? category;
  final int? usages;

  TagDto({
    this.names,
    this.category,
    this.usages,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      names:
          (json['names'] as List<dynamic>?)?.map((e) => e as String).toList(),
      category: json['category'] as String?,
      usages: json['usages'] as int?,
    );
  }
}
