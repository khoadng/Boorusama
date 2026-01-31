// Project imports:
import 'common.dart';

class TagDto {
  TagDto({
    this.names,
    this.category,
    this.usages,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      names: (json['names'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      category: json['category'] as String?,
      usages: json['usages'] as int?,
    );
  }
  final List<String>? names;
  final String? category;
  final int? usages;
}

class TagCategoryDto {
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
      version: SzurubooruVersion.maybeFrom(json['version']),
      color: json['color'] as String?,
      usages: json['usages'] as int?,
      isDefault: json['default'] as bool?,
      order: json['order'] as int?,
    );
  }
  final String? name;
  final SzurubooruVersion? version;
  final String? color;
  final int? usages;
  final bool? isDefault;
  final int? order;
}
