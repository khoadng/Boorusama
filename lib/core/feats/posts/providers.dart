// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/manage/manage.dart';
import 'package:boorusama/core/feats/posts/posts.dart';

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);

final emptyPostRepoProvider = Provider<PostRepository>(
  (ref) => EmptyPostRepository(),
);
