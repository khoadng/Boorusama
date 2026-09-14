// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/bookmark_repository.dart';
import '../types/bookmark_repository_factory.dart';

export 'image_cache.dart';

final bookmarkRepositoryFactoryProvider = Provider<BookmarkRepositoryFactory>(
  (_) => throw UnimplementedError(
    'bookmarkRepositoryFactoryProvider must be overridden',
  ),
  name: 'bookmarkRepositoryFactoryProvider',
);

final bookmarkRepoProvider = FutureProvider<BookmarkRepository>(
  (ref) async {
    final factory = ref.watch(bookmarkRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
  name: 'bookmarkRepoProvider',
);
