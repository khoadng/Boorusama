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

  final int? id;
  final String? name;
  final int? avatarVersion;
  final bool? isAvatar;
  final int? siteScore;
  final List<String>? groups;
  final int? gender;
  final DateTime? registerDate;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    final registerDate = json['register_date'] != null
        ? DateTime.tryParse(json['register_date'])
        : null;

    return UserDto(
      id: json['id'],
      name: json['name'],
      avatarVersion: json['avatar_version'],
      isAvatar: json['isavatar'],
      siteScore: json['site_score'],
      groups: List<String>.from(json['groups']),
      gender: json['gender'],
      registerDate: registerDate,
    );
  }
}

extension UserDtoX on UserDto {
  bool get isExist => id != null;
}
