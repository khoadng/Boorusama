// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';

final postShareProvider =
    NotifierProvider.family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
