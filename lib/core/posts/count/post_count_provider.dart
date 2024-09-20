// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'post_count_repository.dart';

final postCountProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, tags) async {
  final booruBuilder = ref.watch(booruBuilderProvider);
  final fetcher = booruBuilder?.postCountFetcher;
  final tagComposer = ref.watch(postRepoProvider(ref.watchConfig)).tagComposer;

  final postCount = await fetcher?.call(
    ref.watchConfig,
    tags.split(' '),
    tagComposer,
  );

  return postCount;
});

final emptyPostCountRepoProvider =
    Provider<PostCountRepository>((ref) => const EmptyPostCountRepository());
