// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rich_text_controller/rich_text_controller.dart';

// Project imports:
import '../../../configs/config.dart';
import '../../../downloads/filename.dart';
import '../../../posts/post/post.dart';
import '../../../posts/post/providers.dart';
import 'booru_builder.dart';
import 'booru_engine.dart';
import 'booru_repository.dart';

final booruEngineRegistryProvider = Provider<BooruEngineRegistry>(
  (ref) {
    throw UnimplementedError();
  },
  name: 'booruEngineRegistryProvider',
);

final booruBuilderProvider = Provider.family<BooruBuilder?, BooruConfigAuth>(
  (ref, config) {
    final booruBuilder =
        ref.watch(booruEngineRegistryProvider).getBuilder(config.booruType);

    return booruBuilder;
  },
  name: 'currentBooruBuilderProvider',
);

final booruRepoProvider = Provider.family<BooruRepository?, BooruConfigAuth>(
  (ref, config) {
    final booruRepo =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    return booruRepo;
  },
  name: 'currentBooruRepositoryProvider',
);

final postLinkGeneratorProvider =
    Provider.family<PostLinkGenerator, BooruConfigAuth>(
  (ref, config) {
    final repository =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    if (repository == null) return const NoLinkPostLinkGenerator();

    return repository.postLinkGenerator(config);
  },
  name: 'postLinkGeneratorProvider',
);

final downloadFilenameBuilderProvider =
    Provider.family<DownloadFilenameGenerator?, BooruConfigAuth>(
  (ref, config) {
    final repository =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    if (repository == null) {
      return null;
    }

    return repository.downloadFilenameBuilder(config);
  },
  name: 'downloadFilenameBuilderProvider',
);

final queryMatcherProvider = Provider.family<TextMatcher?, BooruConfigAuth>(
  (ref, config) {
    final repository =
        ref.watch(booruEngineRegistryProvider).getRepository(config.booruType);

    if (repository == null) return null;

    return repository.queryMatcher(config);
  },
  name: 'queryMatcherProvider',
);
