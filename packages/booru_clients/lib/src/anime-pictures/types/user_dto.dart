// Project imports:
import 'json_parsing.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.avatarVersion,
    required this.isAvatar,
    required this.siteScore,
    required this.groups,
    required this.gender,
    required this.registerDate,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: intFromJson(json['id']),
      name: stringFromJson(json['name']),
      avatarVersion: intFromJson(json['avatar_version']),
      isAvatar: boolFromJson(json['isavatar']),
      siteScore: intFromJson(json['site_score']),
      groups: stringListFromJson(json['groups']),
      gender: intFromJson(json['gender']),
      registerDate: dateTimeFromJson(json['register_date']),
    );
  }

  final int? id;
  final String? name;
  final int? avatarVersion;
  final bool? isAvatar;
  final int? siteScore;
  final List<String>? groups;
  final int? gender;
  final DateTime? registerDate;
}

extension UserDtoX on UserDto {
  bool get isExist => id != null;
}
