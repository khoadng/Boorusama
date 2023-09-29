// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/booru_user_identity_provider.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/preloaders/preloaders.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

mixin DanbooruPostServiceProviderMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      ref.read(danbooruBlacklistedTagRepoProvider);

  BooruUserIdentityProvider get booruUserIdentityProvider =>
      ref.read(booruUserIdentityProviderProvider);

  BooruConfig get booruConfig => ref.read(currentBooruConfigProvider);

  void Function(List<int> ids) get checkFavorites =>
      (ids) => ref.danbooruFavorites.checkFavorites(ids);

  void Function(List<int> ids) get checkVotes =>
      (ids) => ref.read(danbooruPostVotesProvider.notifier).getVotes(ids);

  PoolRepository get poolRepository => ref.read(danbooruPoolRepoProvider);

  PostPreviewPreloader? get previewPreloader => ref.read(previewLoaderProvider);

  Set<String> get blacklistedTags => {
        ...ref.read(globalBlacklistedTagsProvider).map((e) => e.name),
        ...ref.read(danbooruBlacklistedTagsProvider) ?? [],
      };
}
