// Project imports:
import '../../../post/post.dart';
import '../types/types.dart';

class EmptyFavoriteRepository extends FavoriteRepository<Post> {
  @override
  bool canFavorite() => false;

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async =>
      AddFavoriteStatus.failure;

  @override
  Future<bool> removeFromFavorites(int postId) async => false;

  @override
  bool isPostFavorited(Post post) => false;
}

class FavoriteRepositoryBuilder<T extends Post>
    implements FavoriteRepository<T> {
  FavoriteRepositoryBuilder({
    required this.add,
    required this.remove,
    required this.isFavorited,
    required bool Function() canFavorite,
    this.filter,
  }) : _canFavorite = canFavorite;

  final Future<AddFavoriteStatus> Function(int postId) add;
  final Future<bool> Function(int postId) remove;
  final bool Function(T post) isFavorited;
  final bool Function() _canFavorite;
  final Future<List<int>> Function(List<int> postIds)? filter;

  @override
  bool canFavorite() => _canFavorite();

  @override
  Future<AddFavoriteStatus> addToFavorites(int postId) async {
    return add(postId);
  }

  @override
  Future<bool> removeFromFavorites(int postId) async {
    return remove(postId);
  }

  @override
  bool isPostFavorited(T post) {
    return isFavorited(post);
  }

  @override
  Future<List<int>> filterFavoritedPosts(List<int> postIds) async {
    if (filter != null) {
      return filter!(postIds);
    }
    return [];
  }
}
