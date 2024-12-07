// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/blacklists/providers.dart';
import 'package:boorusama/core/boorus.dart';
import 'package:boorusama/core/configs.dart';
import 'package:boorusama/core/configs/manage.dart';
import '../posts/post/danbooru_post.dart';
import '../users/level/user_level.dart';
import '../users/user/providers.dart';
import 'blacklisted_tags_notifier.dart';

final danbooruBlacklistedTagsProvider = AsyncNotifierProvider.family<
    BlacklistedTagsNotifier, List<String>?, BooruConfigAuth>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final danbooruBlacklistedTagsWithCensoredTagsProvider = FutureProvider
    .autoDispose
    .family<Set<String>, BooruConfigAuth>((ref, config) async {
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
