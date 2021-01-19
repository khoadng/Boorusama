abstract class IFavoritePostRepository {
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
}
