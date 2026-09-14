// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../types/blacklisted_tag_repository.dart';
import '../types/global_blacklisted_tag_repository_factory.dart';

final globalBlacklistedTagRepositoryFactoryProvider =
    Provider<GlobalBlacklistedTagRepositoryFactory>(
      (_) => throw UnimplementedError(
        'globalBlacklistedTagRepositoryFactoryProvider must be overridden',
      ),
      name: 'globalBlacklistedTagRepositoryFactoryProvider',
    );

final globalBlacklistedTagRepoProvider =
    FutureProvider<GlobalBlacklistedTagRepository>(
      (ref) async {
        final factory = ref.watch(
          globalBlacklistedTagRepositoryFactoryProvider,
        );
        final repository = await factory.create();
        ref.onDispose(() => factory.dispose(repository));
        return repository;
      },
      name: 'globalBlacklistedTagRepoProvider',
    );
