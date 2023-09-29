// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/providers.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'blacklisted_tags_notifier.dart';
import 'blacklisted_tags_repository.dart';

final danbooruBlacklistedTagRepoProvider = Provider<BlacklistedTagsRepository>(
  (ref) {
    return BlacklistedTagsRepositoryImpl(
      ref.watch(danbooruUserRepoProvider),
      ref.watch(danbooruClientProvider),
    );
  },
  dependencies: [
    danbooruUserRepoProvider,
    danbooruClientProvider,
  ],
);

final danbooruBlacklistedTagsProvider =
    NotifierProvider.autoDispose<BlacklistedTagsNotifier, List<String>?>(
  BlacklistedTagsNotifier.new,
  dependencies: [
    booruUserIdentityProviderProvider,
    danbooruBlacklistedTagRepoProvider,
    currentBooruConfigProvider,
  ],
);
