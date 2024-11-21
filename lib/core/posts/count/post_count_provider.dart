// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'post_count_repository.dart';

final postCountProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, tags) async {
  final config = ref.watchConfig;
  final fetcher = ref.watch(postCountRepoProvider(config));
  final tagComposer = ref.watch(postRepoProvider(config)).tagComposer;

  if (fetcher == null) return null;

  final postCount = await fetcher.count(tagComposer.compose(tags.split(' ')));

  return postCount;
});

final emptyPostCountRepoProvider =
    Provider<PostCountRepository>((ref) => const EmptyPostCountRepository());
