// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/tags/configs/providers.dart';
import '../../../../../core/tags/metatag/types.dart';
import 'data/factory.dart';
import 'user_metatag_repository.dart';

final danbooruUserMetatagRepositoryFactoryProvider =
    Provider<DanbooruUserMetatagRepositoryFactory>(
      (_) => const HiveDanbooruUserMetatagRepositoryFactory(),
    );

final danbooruUserMetatagRepoProvider = FutureProvider<UserMetatagRepository>(
  (ref) async {
    final factory = ref.watch(danbooruUserMetatagRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final metatagsProvider = Provider<Set<Metatag>>(
  (ref) => ref.watch(tagInfoProvider.select((v) => v.metatags)),
  dependencies: [tagInfoProvider],
);

final danbooruMetatagExtractorProvider =
    Provider.family<DefaultMetatagExtractor, BooruConfigAuth>(
      (ref, config) {
        final tagInfo = ref.watch(tagInfoProvider);
        return DefaultMetatagExtractor(
          metatags: tagInfo.metatags,
        );
      },
      dependencies: [tagInfoProvider],
    );
