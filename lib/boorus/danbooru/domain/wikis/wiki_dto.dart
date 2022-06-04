import 'wiki.dart';

class WikiDto {
  WikiDto({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.body,
    required this.isLocked,
    required this.otherNames,
    required this.isDeleted,
  });

  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String title;
  final String body;
  final bool isLocked;
  final List<dynamic> otherNames;
  final bool isDeleted;

  factory WikiDto.fromJson(Map<String, dynamic> json) => WikiDto(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        title: json["title"],
        body: json["body"],
        isLocked: json["is_locked"],
        otherNames: List<dynamic>.from(json["other_names"].map((x) => x)),
        isDeleted: json["is_deleted"],
      );
}

extension WikiDtoX on WikiDto {
  Wiki toEntity() {
    return Wiki(
      body: body,
      id: id,
      title: title,
      otherNames: List<String>.from(otherNames),
    );
  }
}
