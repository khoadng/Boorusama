// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../users/users.dart';

// Project imports:

class DanbooruFavoriteGroup extends Equatable {
  const DanbooruFavoriteGroup({
    required this.id,
    required this.name,
    required this.creator,
    required this.createdAt,
    required this.updatedAt,
    required this.isPublic,
    required this.postIds,
  });

  final int id;
  final String name;
  final Creator creator;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final List<int> postIds;

  @override
  List<Object?> get props => [id, name, updatedAt, isPublic, postIds];
}

extension FavoriteGroupX on DanbooruFavoriteGroup {
  DanbooruFavoriteGroup copyWith({
    String? name,
    bool? isPublic,
    List<int>? postIds,
  }) =>
      DanbooruFavoriteGroup(
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

abstract class FavoriteGroupRepository {
  Future<List<DanbooruFavoriteGroup>> getFavoriteGroupsByCreatorName({
    required String name,
    int? page,
  });

  Future<bool> createFavoriteGroup({
    required String name,
    List<int>? initialItems,
    bool isPrivate = false,
  });

  Future<bool> editFavoriteGroup({
    required int id,
    String? name,
    List<int>? itemIds,
    bool isPrivate = false,
  });

  Future<bool> deleteFavoriteGroup({
    required int id,
  });

  Future<bool> addItemsToFavoriteGroup({
    required int id,
    required List<int> itemIds,
  });

  Future<bool> removeItemsFromFavoriteGroup({
    required int id,
    required List<int> itemIds,
  });
}
