class WikiDto {
  WikiDto({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.title,
    this.body,
    this.isLocked,
    this.otherNames,
    this.isDeleted,
  });

  factory WikiDto.fromJson(Map<String, dynamic> json) => WikiDto(
        id: json['id'],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        title: json['title'],
        body: json['body'],
        isLocked: json['is_locked'],
        otherNames: json['other_names'] == null
            ? null
            : List<String>.from(json['other_names'].map((x) => x)),
        isDeleted: json['is_deleted'],
      );

  final int? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? title;
  final String? body;
  final bool? isLocked;
  final List<String>? otherNames;
  final bool? isDeleted;
}
