// Project imports:
import 'favorite_tag.dart';

abstract interface class FavoriteTagRepositoryFactory {
  Future<FavoriteTagRepository> create();

  Future<void> dispose(FavoriteTagRepository repository);
}
