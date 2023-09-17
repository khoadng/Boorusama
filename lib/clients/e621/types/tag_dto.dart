class TagDto {
  final int? id;
  final String? name;
  final int? postCount;
  final String? relatedTags;
  final String? relatedTagsUpdatedAt;
  final int? category;
  final bool? isLocked;
  final String? createdAt;
  final String? updatedAt;

  TagDto({
    this.id,
    this.name,
    this.postCount,
    this.relatedTags,
    this.relatedTagsUpdatedAt,
    this.category,
    this.isLocked,
    this.createdAt,
    this.updatedAt,
  });

  factory TagDto.fromJson(Map<String, dynamic> json) {
    return TagDto(
      id: json['id'],
      name: json['name'],
      postCount: json['post_count'],
      relatedTags: json['related_tags'],
      relatedTagsUpdatedAt: json['related_tags_updated_at'],
      category: json['category'],
      isLocked: json['is_locked'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  @override
  String toString() => name ?? '';
}
