abstract class IFavoritePostRepository {
  Future addToFavorites(int postId);
  Future removeFromFavorites(int postId);
}
