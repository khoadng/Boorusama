// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'post_count_repository.dart';

final postCountProvider =
    FutureProvider.autoDispose.family<int?, String>((ref, tags) async {
  final booruBuilder = ref.watch(booruBuilderProvider);
  final fetcher = booruBuilder?.postCountFetcher;

  final postCount = await fetcher?.call(tags.split(' '));

  return postCount;
});

final emptyPostCountRepoProvider =
    Provider<PostCountRepository>((ref) => const EmptyPostCountRepository());
