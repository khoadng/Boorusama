// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';
import '../domain/posts.dart';
import 'post_share_notifier.dart';

final postShareProvider =
    NotifierProvider.family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
