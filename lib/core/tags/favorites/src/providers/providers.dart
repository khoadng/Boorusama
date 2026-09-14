// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/favorite_tag.dart';
import '../types/favorite_tag_repository_factory.dart';

final favoriteTagRepositoryFactoryProvider =
    Provider<FavoriteTagRepositoryFactory>(
      (_) => throw UnimplementedError(
        'favoriteTagRepositoryFactoryProvider must be overridden',
      ),
      name: 'favoriteTagRepositoryFactoryProvider',
    );

final favoriteTagRepoProvider = FutureProvider<FavoriteTagRepository>((
  ref,
) async {
  final factory = ref.watch(favoriteTagRepositoryFactoryProvider);
  final repository = await factory.create();
  ref.onDispose(() => factory.dispose(repository));

  return repository;
});
