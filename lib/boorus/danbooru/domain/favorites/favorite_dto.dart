// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';

part 'favorite_dto.freezed.dart';
part 'favorite_dto.g.dart';

@freezed
abstract class FavoriteDto with _$FavoriteDto {
  const factory FavoriteDto(
    int id,
    int user_id,
    int post_id,
  ) = _FavoriteDto;

  factory FavoriteDto.fromJson(Map<String, dynamic> json) =>
      _$FavoriteDtoFromJson(json);
}

extension FavoriteDtoX on FavoriteDto {}
