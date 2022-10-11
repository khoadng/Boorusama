// Project imports:
import 'favorite_dto.dart';

abstract class IFavoritePostRepository {
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
  Future<List<FavoriteDto>> filterFavoritesFromUserId(
      List<int> postIds, int userId, int limit);
  Future<bool> checkIfFavoritedByUser(int userId, int postId);
  Future<List<FavoriteDto>> getFavorites(int postId, int page);
}
