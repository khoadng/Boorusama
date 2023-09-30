// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'blacklisted_tags_notifier.dart';
import 'blacklisted_tags_repository.dart';

final danbooruBlacklistedTagRepoProvider =
    Provider.family<BlacklistedTagsRepository, BooruConfig>(
  (ref, config) {
    return BlacklistedTagsRepositoryImpl(
      ref.watch(danbooruUserRepoProvider(config)),
      ref.watch(danbooruClientProvider(config)),
    );
  },
);

final danbooruBlacklistedTagsProvider = NotifierProvider.autoDispose
    .family<BlacklistedTagsNotifier, List<String>?, BooruConfig>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    danbooruBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
