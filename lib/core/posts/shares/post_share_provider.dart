// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/current.dart';
import '../post.dart';
import 'post_share_notifier.dart';

final postShareProvider = NotifierProvider.autoDispose
    .family<PostShareNotifier, PostShareState, Post>(
  PostShareNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
    booruFactoryProvider,
  ],
);
