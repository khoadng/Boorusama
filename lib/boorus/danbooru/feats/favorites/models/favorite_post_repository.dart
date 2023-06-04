// Project imports:
import 'favorite.dart';

abstract class FavoritePostRepository {
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
  Future<List<Favorite>> filterFavoritesFromUserId(
    List<int> postIds,
    int userId,
    int limit,
  );
  Future<bool> checkIfFavoritedByUser(int userId, int postId);
  Future<List<Favorite>> getFavorites(int postId, int page);
}
