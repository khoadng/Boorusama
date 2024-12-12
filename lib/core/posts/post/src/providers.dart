// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../boorus/providers.dart';
import '../../../configs/config.dart';
import 'post_repository.dart';

final emptyPostRepoProvider = Provider<PostRepository>(
  (ref) => EmptyPostRepository(),
);

final postRepoProvider = Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final repo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    final postRepo = repo?.post(config);

    if (postRepo != null) {
      return postRepo;
    }

    return ref.watch(emptyPostRepoProvider);
  },
);
