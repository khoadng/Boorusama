// Project imports:
import 'artist.dart';

class ArtistDto {
  ArtistDto({
    this.id,
    this.createdAt,
    this.name,
    this.updatedAt,
    this.isDeleted,
    this.groupName,
    this.isBanned,
    this.otherNames,
  });

  final int id;
  final DateTime createdAt;
  final String name;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;

  factory ArtistDto.fromJson(Map<String, dynamic> json) => ArtistDto(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        name: json["name"],
        updatedAt: DateTime.parse(json["updated_at"]),
        isDeleted: json["is_deleted"],
        groupName: json["group_name"],
        isBanned: json["is_banned"],
        otherNames: List<String>.from(json["other_names"].map((x) => x)),
      );
}

extension ArtistDtoX on ArtistDto {
  Artist toEntity() {
    return Artist(
      createdAt: createdAt,
      id: id,
      name: name,
      groupName: groupName,
      isBanned: isBanned,
      isDeleted: isDeleted,
      otherNames: List<String>.from(otherNames),
      updatedAt: updatedAt,
    );
  }
}
