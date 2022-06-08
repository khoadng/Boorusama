// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';

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

  factory PoolDto.fromJson(Map<String, dynamic> json) => PoolDto(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        description: json["description"] == null ? null : json["description"],
        isActive: json["is_active"] == null ? null : json["is_active"],
        isDeleted: json["is_deleted"] == null ? null : json["is_deleted"],
        postIds: json["post_ids"] == null
            ? null
            : List<int>.from(json["post_ids"].map((x) => x)),
        category: json["category"] == null ? null : json["category"],
        postCount: json["post_count"] == null ? null : json["post_count"],
      );
}

Pool poolDtoToPool(PoolDto dto) => Pool(
      id: dto.id!,
      postIds: dto.postIds!,
      category: _stringToPoolCategory(dto.category),
      description: dto.description!,
      postCount: PoolPostCount(dto.postCount!),
      name: PoolName(dto.name!),
      createdAt: dto.createdAt!,
    );

PoolCategory _stringToPoolCategory(String? value) {
  switch (value) {
    case "collection":
      return PoolCategory.collection;
    case "series":
      return PoolCategory.series;
    default:
      return PoolCategory.unknown;
  }
}
