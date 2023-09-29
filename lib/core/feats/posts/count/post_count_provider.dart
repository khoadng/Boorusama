// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'post_count_notifier.dart';
import 'post_count_repository.dart';
import 'post_count_state.dart';

final postCountStateProvider =
    NotifierProvider.family<PostCountNotifier, PostCountState, BooruConfig>(
  PostCountNotifier.new,
);

final postCountProvider = Provider<PostCountState>(
  (ref) =>
      ref.watch(postCountStateProvider(ref.watch(currentBooruConfigProvider))),
  dependencies: [
    postCountStateProvider,
    currentBooruConfigProvider,
  ],
);

final emptyPostCountRepoProvider =
    Provider<PostCountRepository>((ref) => const EmptyPostCountRepository());
