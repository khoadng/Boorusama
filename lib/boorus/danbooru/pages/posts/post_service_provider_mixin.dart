// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/features/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/features/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/features/posts/app.dart';
import 'package:boorusama/boorus/danbooru/features/tags/tags.dart';
import 'package:boorusama/core/booru_user_identity_provider.dart';
import 'package:boorusama/core/boorus/boorus.dart';
import 'package:boorusama/core/preloaders/preloaders.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/tags/tags.dart';

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
}
