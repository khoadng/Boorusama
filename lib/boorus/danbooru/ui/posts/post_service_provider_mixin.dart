// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus/current_booru_config_repository.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

mixin DanbooruPostServiceProviderMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  void Function(List<int> ids) get checkFavorites =>
      (ids) => ref.danbooruFavorites.checkFavorites(ids);

  PoolRepository get poolRepository => context.read<PoolRepository>();

  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
}
