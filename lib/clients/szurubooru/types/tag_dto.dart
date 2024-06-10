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

class TagCategoryDto {
  final String? name;
  final int? version;
  final String? color;
  final int? usages;
  final bool? isDefault;
  final int? order;

  TagCategoryDto({
    required this.name,
    required this.version,
    required this.color,
    required this.usages,
    required this.isDefault,
    required this.order,
  });

  factory TagCategoryDto.fromJson(Map<String, dynamic> json) {
    return TagCategoryDto(
      name: json['name'] as String?,
      version: json['version'] as int?,
      color: json['color'] as String?,
      usages: json['usages'] as int?,
      isDefault: json['default'] as bool?,
      order: json['order'] as int?,
    );
  }
}
