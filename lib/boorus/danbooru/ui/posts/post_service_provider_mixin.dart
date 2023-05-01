// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pool_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/domain/boorus/current_booru_config_repository.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';
import 'package:boorusama/core/domain/tags/blacklisted_tags_repository.dart';

mixin DanbooruPostServiceProviderMixin<T extends StatefulWidget> on State<T> {
  BlacklistedTagsRepository get blacklistedTagsRepository =>
      context.read<BlacklistedTagsRepository>();

  BooruUserIdentityProvider get booruUserIdentityProvider =>
      context.read<BooruUserIdentityProvider>();

  CurrentBooruConfigRepository get currentBooruConfigRepository =>
      context.read<CurrentBooruConfigRepository>();

  FavoritePostCubit get favoriteCubit => context.read<FavoritePostCubit>();

  PoolRepository get poolRepository => context.read<PoolRepository>();

  PostVoteCubit get postVoteCubit => context.read<PostVoteCubit>();

  PostVoteRepository get postVoteRepository =>
      context.read<PostVoteRepository>();

  PostPreviewPreloader? get previewPreloader =>
      context.read<PostPreviewPreloader>();
}
