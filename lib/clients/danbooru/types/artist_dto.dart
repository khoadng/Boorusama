// Project imports:
import 'artist_url_dto.dart';

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
    required this.urls,
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
        urls: List<ArtistUrlDto>.from(
            json['urls'].map((x) => ArtistUrlDto.fromJson(x))),
      );

  final int id;
  final DateTime createdAt;
  final String name;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;
  final List<ArtistUrlDto> urls;

  @override
  String toString() => name;
}
