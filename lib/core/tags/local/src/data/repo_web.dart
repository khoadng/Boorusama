// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../foundation/filesystem.dart';
import '../types/tag_cache_repository.dart';
import '../types/tag_cache_repository_factory.dart';
import 'repo_empty.dart';

final tagCacheRepositoryFactoryProvider = Provider<TagCacheRepositoryFactory>(
  (_) => const EmptyTagCacheRepositoryFactory(),
);

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) async {
    final factory = ref.watch(tagCacheRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final class EmptyTagCacheRepositoryFactory
    implements TagCacheRepositoryFactory {
  const EmptyTagCacheRepositoryFactory();

  @override
  Future<TagCacheRepository> create() async => EmptyTagCacheRepository();

  @override
  Future<void> dispose(TagCacheRepository repository) => repository.dispose();
}

Future<String> getTagCacheDbPath(AppFileSystem fs) async {
  return '';
}
