// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'artist.dart';

part 'artist_dto.freezed.dart';
part 'artist_dto.g.dart';

@freezed
abstract class ArtistDto with _$ArtistDto {
  const factory ArtistDto(
    int id,
    String created_at,
    String name,
    String updated_at,
    bool is_deleted,
    String group_name,
    bool is_banned,
    List<dynamic> other_names,
  ) = _ArtistDto;

  factory ArtistDto.fromJson(Map<String, dynamic> json) =>
      _$ArtistDtoFromJson(json);
}

extension ArtistDtoX on ArtistDto {
  Artist toEntity() {
    return Artist(
      createdAt: DateTime.parse(created_at),
      id: id,
      name: name,
      groupName: group_name,
      isBanned: is_banned,
      isDeleted: is_deleted,
      otherNames: List<String>.from(other_names),
      updatedAt: DateTime.parse(updated_at),
    );
  }
}
