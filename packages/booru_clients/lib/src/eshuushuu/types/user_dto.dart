class UserDto {
  UserDto({
    this.userId,
    this.username,
    this.location,
    this.website,
    this.interests,
    this.userTitle,
    this.avatar,
    this.gender,
    this.posts,
    this.imagePosts,
    this.favorites,
    this.dateJoined,
    this.lastLogin,
    this.lastActive,
    this.active,
    this.admin,
    this.groups,
    this.maxImgPerDay,
    this.avatarUrl,
  });

  final int? userId;
  final String? username;
  final String? location;
  final String? website;
  final String? interests;
  final String? userTitle;
  final String? avatar;
  final String? gender;
  final int? posts;
  final int? imagePosts;
  final int? favorites;
  final DateTime? dateJoined;
  final DateTime? lastLogin;
  final DateTime? lastActive;
  final bool? active;
  final bool? admin;
  final List<String>? groups;
  final int? maxImgPerDay;
  final String? avatarUrl;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      userId: json['user_id'] as int?,
      username: json['username'] as String?,
      location: json['location'] as String?,
      website: json['website'] as String?,
      interests: json['interests'] as String?,
      userTitle: json['user_title'] as String?,
      avatar: json['avatar'] as String?,
      gender: json['gender'] as String?,
      posts: json['posts'] as int?,
      imagePosts: json['image_posts'] as int?,
      favorites: json['favorites'] as int?,
      dateJoined: switch (json['date_joined']) {
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      lastLogin: switch (json['last_login']) {
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      lastActive: switch (json['last_active']) {
        final String s => DateTime.tryParse(s),
        _ => null,
      },
      active: json['active'] as bool?,
      admin: json['admin'] as bool?,
      groups: switch (json['groups']) {
        final List list => list.whereType<String>().toList(),
        _ => null,
      },
      maxImgPerDay: json['maximgperday'] as int?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
