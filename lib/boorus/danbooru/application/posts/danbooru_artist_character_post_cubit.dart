// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/posts/danbooru_artist_character_post_repository.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/application/tags.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

typedef DanbooruArtistCharacterPostState
    = PostState<DanbooruPost, DanbooruArtistChararacterExtra>;

class DanbooruArtistChararacterExtra extends Equatable {
  final TagFilterCategory category;
  final String tag;

  const DanbooruArtistChararacterExtra({
    required this.category,
    required this.tag,
  });

  @override
  List<Object?> get props => [category, tag];

  DanbooruArtistChararacterExtra copyWith({
    TagFilterCategory? category,
    String? tag,
  }) {
    return DanbooruArtistChararacterExtra(
      category: category ?? this.category,
      tag: tag ?? this.tag,
    );
  }
}

class DanbooruArtistCharacterPostCubit with DanbooruPostTransformMixin {
  DanbooruArtistCharacterPostCubit({
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.currentBooruConfigRepository,
    required this.booruUserIdentityProvider,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
    required this.postVoteCubit,
    required this.favoriteCubit,
  });

  factory DanbooruArtistCharacterPostCubit.of(
    BuildContext context, {
    required DanbooruArtistChararacterExtra extra,
  }) =>
      DanbooruArtistCharacterPostCubit(
        postRepository: context.read<DanbooruArtistCharacterPostRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        currentBooruConfigRepository:
            context.read<CurrentBooruConfigRepository>(),
        booruUserIdentityProvider: context.read<BooruUserIdentityProvider>(),
        favoriteCubit: context.read<FavoritePostCubit>(),
        postVoteCubit: context.read<PostVoteCubit>(),
      );

  final DanbooruPostRepository postRepository;
  @override
  final BlacklistedTagsRepository blacklistedTagsRepository;
  @override
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  @override
  final BooruUserIdentityProvider booruUserIdentityProvider;
  @override
  final PostVoteRepository postVoteRepository;
  @override
  final PoolRepository poolRepository;
  @override
  PostPreviewPreloader? previewPreloader;
  @override
  FavoritePostCubit favoriteCubit;
  @override
  PostVoteCubit postVoteCubit;

  Future<List<DanbooruPost>> refreshPost(
    DanbooruArtistChararacterExtra extra,
  ) async =>
      postRepository
          .getPosts(
            _extraToTagString(extra),
            1,
          )
          .then(transform);

  Future<List<DanbooruPost>> fetchPost(
    int page,
    DanbooruArtistChararacterExtra extra,
  ) async =>
      postRepository
          .getPosts(
            _extraToTagString(extra),
            page,
          )
          .then(transform);
}

String _extraToTagString(DanbooruArtistChararacterExtra extra) => [
      _tagFilterCategoryToString(extra.category),
      extra.tag,
    ].whereNotNull().join(' ');

String? _tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? "order:score" : null;

mixin DanbooruArtistCharacterPostCubitMixin<T extends StatefulWidget>
    on State<T> {
  Future<List<DanbooruPost>> refreshPost(
    DanbooruArtistChararacterExtra extra,
  ) =>
      context.read<DanbooruArtistCharacterPostCubit>().refreshPost(extra);

  Future<List<DanbooruPost>> fetchPost(
    int page,
    DanbooruArtistChararacterExtra extra,
  ) =>
      context.read<DanbooruArtistCharacterPostCubit>().fetchPost(page, extra);
}
