import 'package:boorusama/boorus/danbooru/domain/favorites.dart';

class EmptyFavoritePostRepository implements FavoritePostRepository {
  @override
  Future<bool> addToFavorites(int postId) async => true;

  @override
  Future<bool> checkIfFavoritedByUser(int userId, int postId) async => true;

  @override
  Future<List<Favorite>> filterFavoritesFromUserId(
    List<int> postIds,
    int userId,
    int limit,
  ) async =>
      [];

  @override
  Future<List<Favorite>> getFavorites(int postId, int page) async => [];

  @override
  Future<bool> removeFromFavorites(int postId) async => true;
}
