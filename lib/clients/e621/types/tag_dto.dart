class TagDto {
  final int? id;
  final String? name;
  final int? postCount;
  final List<RelatedTagDto>? relatedTags;
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
    final tags = _parseRelatedTags(json['related_tags']);

    return TagDto(
      id: json['id'],
      name: json['name'],
      postCount: json['post_count'],
      relatedTags: tags,
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

class RelatedTagDto {
  final String tag;
  final double score;

  const RelatedTagDto({
    required this.tag,
    required this.score,
  });
}

List<RelatedTagDto>? _parseRelatedTags(String? relatedTags) {
  if (relatedTags == null) return null;

  final parts = relatedTags.split(' ');

  final tags = <RelatedTagDto>[];

  for (var i = 0; i < parts.length; i += 2) {
    final tag = parts[i];
    final score = double.tryParse(parts[i + 1]) ?? 0.0;

    tags.add(RelatedTagDto(
      tag: tag,
      score: score,
    ));
  }

  return tags;
}
