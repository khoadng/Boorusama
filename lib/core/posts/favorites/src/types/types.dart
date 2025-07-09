// Project imports:
import '../../../post/post.dart';

enum AddFavoriteStatus {
  success,
  failure,
  alreadyExists,
}

abstract class FavoriteRepository<T extends Post> {
  bool canFavorite();
  Future<AddFavoriteStatus> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
  bool isPostFavorited(T post);
  Future<List<int>> filterFavoritedPosts(List<int> postIds) async {
    return [];
  }
}
