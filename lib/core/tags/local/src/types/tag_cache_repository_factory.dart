import 'tag_cache_repository.dart';

abstract interface class TagCacheRepositoryFactory {
  Future<TagCacheRepository> create();

  Future<void> dispose(TagCacheRepository repository);
}
