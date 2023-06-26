// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'post_count_notifier.dart';
import 'post_count_repository.dart';
import 'post_count_state.dart';

final postCountRepoProvider = Provider<PostCountRepository>((ref) {
  throw UnimplementedError();
});

final postCountStateProvider =
    NotifierProvider<PostCountNotifier, PostCountState>(
  PostCountNotifier.new,
  dependencies: [
    postCountRepoProvider,
    currentBooruConfigProvider,
  ],
);

final postCountProvider = Provider<PostCountState>(
  (ref) => ref.watch(postCountStateProvider),
  dependencies: [
    postCountStateProvider,
  ],
);
