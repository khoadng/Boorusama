// Package imports:
import 'package:booru_clients/danbooru.dart';

// Project imports:
import '../types/favorite.dart';

Favorite favoriteDtoToFavorite(FavoriteDto d) => Favorite(
  id: d.id,
  postId: d.postId,
  userId: d.userId,
);
