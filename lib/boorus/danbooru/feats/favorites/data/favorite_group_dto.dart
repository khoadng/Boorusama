// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/users/creator.dart';

class FavoriteGroupDto {
  FavoriteGroupDto({
    required this.id,
    required this.name,
    required this.creator,
    required this.postIds,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublic,
  });

  factory FavoriteGroupDto.fromJson(Map<String, dynamic> json) =>
      FavoriteGroupDto(
        id: json['id'],
        name: json['name'],
        creator: json['creator'] == null
            ? null
            : CreatorDto.fromJson(json['creator']),
        postIds: json['post_ids'] == null
            ? null
            : List<int>.from(json['post_ids'].map((x) => x)),
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json['created_at']),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json['updated_at']),
        isPublic: json['is_public'],
      );

  final int? id;
  final String? name;
  final CreatorDto? creator;
  final List<int>? postIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isPublic;
}

FavoriteGroup favoriteGroupDtoToFavoriteGroup(FavoriteGroupDto d) =>
    FavoriteGroup(
      id: d.id!,
      name: d.name ?? '',
      creator:
          d.creator == null ? Creator.empty() : creatorDtoToCreator(d.creator!),
      createdAt: d.createdAt!,
      updatedAt: d.updatedAt!,
      isPublic: d.isPublic ?? false,
      postIds: d.postIds ?? [],
    );
