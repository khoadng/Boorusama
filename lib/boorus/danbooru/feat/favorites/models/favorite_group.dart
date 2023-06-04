// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feat/favorites/models/creator.dart';

class FavoriteGroup extends Equatable {
  const FavoriteGroup({
    required this.id,
    required this.name,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublic,
    required this.postIds,
  });

  final FavoriteGroupId id;
  final FavoriteGroupName name;
  final Creator creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<int> postIds;

  @override
  List<Object?> get props => [id, name, updatedAt, isPublic, postIds];
}

typedef FavoriteGroupId = int;
typedef FavoriteGroupName = String;

extension FavoriteGroupX on FavoriteGroup {
  FavoriteGroup copyWith({
    String? name,
    bool? isPublic,
    List<int>? postIds,
  }) =>
      FavoriteGroup(
        id: id,
        name: name ?? this.name,
        creator: creator,
        createdAt: createdAt,
        updatedAt: updatedAt,
        isPublic: isPublic ?? this.isPublic,
        postIds: postIds ?? this.postIds,
      );

  int get totalCount => postIds.length;
  String getQueryString() => 'favgroup:$id';
}
