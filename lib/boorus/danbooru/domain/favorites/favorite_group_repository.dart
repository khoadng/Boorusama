// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';

abstract class FavoriteGroupRepository {
  Future<List<FavoriteGroup>> getFavoriteGroups({
    String? name,
    int? page,
  });

  Future<List<FavoriteGroup>> getFavoriteGroupsByCreatorName({
    required String name,
    int? page,
  });
}
