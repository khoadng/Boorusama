// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_dto.dart';

abstract class IFavoritePostRepository {
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
  Future<List<FavoriteDto>> filterFavoritesFromUserId(
      List<int> postIds, int userId);
}
