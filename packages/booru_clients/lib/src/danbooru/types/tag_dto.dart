class TagDto {
  TagDto({
    required this.id,
    required this.name,
    required this.postCount,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeprecated,
    required this.words,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) => TagDto(
        id: json['id'],
        name: json['name'],
        postCount: json['post_count'],
        category: json['category'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        isDeprecated: json['is_deprecated'],
        words: json['words'] == null
            ? null
            : List<String>.from(json['words'].map((x) => x)),
      );

  final int? id;
  final String? name;
  final int? postCount;
  final int? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDeprecated;
  final List<String>? words;

  @override
  String toString() => name ?? '';
}
