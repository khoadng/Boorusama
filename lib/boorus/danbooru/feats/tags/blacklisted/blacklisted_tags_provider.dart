// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'blacklisted_tags_notifier.dart';

final danbooruBlacklistedTagsProvider = AsyncNotifierProvider.autoDispose
    .family<BlacklistedTagsNotifier, List<String>?, BooruConfig>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruBlacklistedTagsWithCensoredTagsProvider = FutureProvider
    .autoDispose
    .family<Set<String>, BooruConfig>((ref, config) async {
  final currentUser =
      await ref.watch(danbooruCurrentUserProvider(config).future);
  final globalBlacklistedTags =
      ref.watch(globalBlacklistedTagsProvider).map((e) => e.name);

  if (currentUser == null) {
    return globalBlacklistedTags.toSet();
  }

  final danbooruBlacklistedTags =
      await ref.watch(danbooruBlacklistedTagsProvider(config).future);
  final isUnverified = config.isUnverified();
  final booruFactory = ref.watch(booruFactoryProvider);
  final censoredTagsBanned = booruFactory
          .create(type: config.booruType)
          ?.hasCensoredTagsBanned(config.url) ??
      false;

  return {
    ...globalBlacklistedTags,
    if (danbooruBlacklistedTags != null) ...danbooruBlacklistedTags,
    if (!isUnverified &&
        censoredTagsBanned &&
        !isBooruGoldPlusAccount(currentUser.level))
      ...kCensoredTags,
  };
});
