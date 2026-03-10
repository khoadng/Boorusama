// Package imports:
import 'package:booru_clients/eshuushuu.dart';
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../core/users/types.dart';

class EshuushuuUser extends Equatable implements User {
  const EshuushuuUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.dateJoined,
    this.lastActive,
    this.uploadCount = 0,
    this.favoriteCount = 0,
    this.forumPostCount = 0,
    this.isAdmin = false,
    this.gender,
    this.website,
    this.userTitle,
    this.groups = const [],
    this.location,
    this.interests,
  });

  factory EshuushuuUser.fromDto(UserDto dto) {
    return EshuushuuUser(
      id: dto.userId ?? 0,
      name: dto.username ?? '',
      avatarUrl: dto.avatarUrl,
      dateJoined: dto.dateJoined,
      lastActive: dto.lastActive,
      uploadCount: dto.imagePosts ?? 0,
      favoriteCount: dto.favorites ?? 0,
      forumPostCount: dto.posts ?? 0,
      isAdmin: dto.admin ?? false,
      gender: _nonEmpty(dto.gender),
      website: _nonEmpty(dto.website),
      userTitle: _nonEmpty(dto.userTitle),
      groups: dto.groups ?? const [],
      location: _nonEmpty(dto.location),
      interests: _nonEmpty(dto.interests),
    );
  }

  @override
  final int id;
  @override
  final String name;
  final String? avatarUrl;
  final DateTime? dateJoined;
  final DateTime? lastActive;
  final int uploadCount;
  final int favoriteCount;
  final int forumPostCount;
  final bool isAdmin;
  final String? gender;
  final String? website;
  final String? userTitle;
  final List<String> groups;
  final String? location;
  final String? interests;

  bool get hasUploads => uploadCount > 0;
  bool get hasFavorites => favoriteCount > 0;
  bool get hasPersonalInfo =>
      gender != null ||
      website != null ||
      location != null ||
      interests != null;

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    dateJoined,
    lastActive,
    uploadCount,
    favoriteCount,
    forumPostCount,
    isAdmin,
    gender,
    website,
    userTitle,
    groups,
    location,
    interests,
  ];
}

String? _nonEmpty(String? s) => (s != null && s.isNotEmpty) ? s : null;
