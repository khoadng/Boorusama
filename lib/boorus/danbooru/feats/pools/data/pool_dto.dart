class PoolDto {
  PoolDto({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.description,
    this.isActive,
    this.isDeleted,
    this.postIds,
    this.category,
    this.postCount,
  });

  factory PoolDto.fromJson(Map<String, dynamic> json) => PoolDto(
        id: json['id'],
        name: json['name'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        description: json['description'],
        isActive: json['is_active'],
        isDeleted: json['is_deleted'],
        postIds: json['post_ids'] == null
            ? null
            : List<int>.from(json['post_ids'].map((x) => x)),
        category: json['category'],
        postCount: json['post_count'],
      );

  final int? id;
  final String? name;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? description;
  final bool? isActive;
  final bool? isDeleted;
  final List<int>? postIds;
  final String? category;
  final int? postCount;
}
