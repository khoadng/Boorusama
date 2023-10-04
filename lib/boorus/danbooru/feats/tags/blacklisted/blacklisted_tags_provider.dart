// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'blacklisted_tags_notifier.dart';

final danbooruBlacklistedTagsProvider = AsyncNotifierProvider.autoDispose
    .family<BlacklistedTagsNotifier, List<String>?, BooruConfig>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);
