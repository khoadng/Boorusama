// Project imports:
import 'json_parsing.dart';

class FavoriteDto {
  FavoriteDto({
    required this.id,
    required this.juserId,
    required this.post,
    required this.addtime,
    required this.folder,
  });

  factory FavoriteDto.fromJson(Map<String, dynamic> json) {
    return FavoriteDto(
      id: intFromJson(json['id']),
      juserId: intFromJson(json['juser_id']),
      post: intFromJson(json['post']),
      addtime: dateTimeFromJson(json['addtime']),
      folder: json['folder'],
    );
  }

  final int? id;
  final int? juserId;
  final int? post;
  final DateTime? addtime;
  final dynamic folder;
}
