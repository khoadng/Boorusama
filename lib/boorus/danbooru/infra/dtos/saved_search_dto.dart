class SavedSearchDto {
  SavedSearchDto({
    required this.id,
    required this.userId,
    required this.query,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
  });

  factory SavedSearchDto.fromJson(Map<String, dynamic> json) => SavedSearchDto(
        id: json['id'],
        userId: json['user_id'],
        query: json['query'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        labels: json['labels'] == null
            ? null
            : List<String>.from(json['labels'].map((x) => x)),
      );

  final int? id;
  final int? userId;
  final String? query;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<String>? labels;
}
