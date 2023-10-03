// Project imports:
import 'package:boorusama/clients/e621/e621_client.dart';

abstract interface class E621FavoritesRepository {
  Future<bool> addToFavorites(int postId);
  Future<bool> removeFromFavorites(int postId);
}

class E621FavoritesRepositoryApi implements E621FavoritesRepository {
  E621FavoritesRepositoryApi(
    this.client,
  );

  final E621Client client;

  @override
  Future<bool> addToFavorites(int postId) => client
      .addToFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);

  @override
  Future<bool> removeFromFavorites(int postId) => client
      .removeFromFavorites(postId: postId)
      .then((value) => true)
      .catchError((obj) => false);
}
