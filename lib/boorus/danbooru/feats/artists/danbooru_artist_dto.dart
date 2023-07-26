// Project imports:
import 'danbooru_artist_url_dto.dart';

class DanbooruArtistDto {
  DanbooruArtistDto({
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

  factory DanbooruArtistDto.fromJson(Map<String, dynamic> json) =>
      DanbooruArtistDto(
        id: json['id'],
        createdAt: DateTime.parse(json['created_at']),
        name: json['name'],
        updatedAt: DateTime.parse(json['updated_at']),
        isDeleted: json['is_deleted'],
        groupName: json['group_name'],
        isBanned: json['is_banned'],
        otherNames: List<String>.from(json['other_names'].map((x) => x)),
        urls: List<DanbooruArtistUrlDto>.from(
            json['urls'].map((x) => DanbooruArtistUrlDto.fromJson(x))),
      );

  final int id;
  final DateTime createdAt;
  final String name;
  final DateTime updatedAt;
  final bool isDeleted;
  final String groupName;
  final bool isBanned;
  final List<String> otherNames;
  final List<DanbooruArtistUrlDto> urls;
}
