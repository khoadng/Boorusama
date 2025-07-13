// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/config.dart';
import '../types/post_link_generator.dart';
import '../types/post_repository.dart';
import 'post_link_generator_impl.dart';
import 'post_repository_impl.dart';

final emptyPostRepoProvider = Provider<PostRepository>(
  (ref) => EmptyPostRepository(),
);

final postRepoProvider = Provider.family<PostRepository, BooruConfigSearch>(
  (ref, config) {
    final repo = ref
        .watch(booruEngineRegistryProvider)
        .getRepository(config.booruType);

    final postRepo = repo?.post(config);

    if (postRepo != null) {
      return postRepo;
    }

    return ref.watch(emptyPostRepoProvider);
  },
);

final postLinkGeneratorProvider =
    Provider.family<PostLinkGenerator, BooruConfigAuth>(
      (ref, config) {
        final repository = ref
            .watch(booruEngineRegistryProvider)
            .getRepository(config.booruType);

        if (repository == null) return const NoLinkPostLinkGenerator();

        return repository.postLinkGenerator(config);
      },
      name: 'postLinkGeneratorProvider',
    );
