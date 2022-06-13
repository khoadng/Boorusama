// Project imports:
import 'artist.dart';

class ArtistDto {
  ArtistDto({
    required this.id,
    required this.createdAt,
    required this.name,
    required this.updatedAt,
    required this.isDeleted,
    required this.groupName,
    required this.isBanned,
    required this.otherNames,
  });

  factory ArtistDto.fromJson(Map<String, dynamic> json) => ArtistDto(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        name: json['name'],
        updatedAt: DateTime.parse(json['updated_at']),
        isDeleted: json['is_deleted'],
        groupName: json['group_name'],
        isBanned: json['is_banned'],
        otherNames: List<String>.from(json['other_names'].map((x) => x)),
      );

  final int id;
  final DateTime createdAt;
  final String name;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;
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
