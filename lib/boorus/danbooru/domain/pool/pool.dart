class Pool {
  Pool({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.description,
    required this.isActive,
    required this.isDeleted,
    required this.postIds,
    required this.category,
    required this.postCount,
  });

  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String description;
  final bool isActive;
  final bool isDeleted;
  final List<int> postIds;
  final String category;
  final int postCount;

  factory Pool.fromJson(Map<String, dynamic> json) => Pool(
        id: json["id"],
        name: json["name"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        description: json["description"],
        isActive: json["is_active"],
        isDeleted: json["is_deleted"],
        postIds: List<int>.from(json["post_ids"].map((x) => x)),
        category: json["category"],
        postCount: json["post_count"],
      );
}
