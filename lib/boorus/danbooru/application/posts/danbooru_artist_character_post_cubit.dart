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
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

enum TagFilterCategory {
  popular,
  newest,
}

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

class DanbooruArtistCharacterPostCubit
    extends PostCubit<DanbooruPost, DanbooruArtistChararacterExtra>
    with DanbooruPostTransformMixin {
  DanbooruArtistCharacterPostCubit({
    required DanbooruArtistChararacterExtra extra,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.currentBooruConfigRepository,
    required this.booruUserIdentityProvider,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
    required this.postVoteCubit,
    required this.favoriteCubit,
  }) : super(initial: PostState.initial(extra));

  factory DanbooruArtistCharacterPostCubit.of(
    BuildContext context, {
    required DanbooruArtistChararacterExtra extra,
  }) =>
      DanbooruArtistCharacterPostCubit(
        extra: extra,
        postRepository: context.read<DanbooruPostRepository>(),
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

  @override
  Future<List<DanbooruPost>> Function(int page) get fetcher =>
      (page) => postRepository
          .getPosts(
            _extraToTagString(state.extra),
            page,
          )
          .then(transform);

  @override
  Future<List<DanbooruPost>> Function() get refresher => () => postRepository
      .getPosts(
        _extraToTagString(state.extra),
        1,
      )
      .then(transform);

  void changeCategory(TagFilterCategory category) => emit(state.copyWith(
        extra: state.extra.copyWith(
          category: category,
        ),
      ));
}

String _extraToTagString(DanbooruArtistChararacterExtra extra) => [
      _tagFilterCategoryToString(extra.category),
      extra.tag,
    ].whereNotNull().join(' ');

String? _tagFilterCategoryToString(TagFilterCategory category) =>
    category == TagFilterCategory.popular ? "order:score" : null;

mixin DanbooruArtistCharacterPostCubitMixin on StatelessWidget {
  void refresh(BuildContext context) =>
      context.read<DanbooruArtistCharacterPostCubit>().refresh();
  void fetch(BuildContext context) =>
      context.read<DanbooruArtistCharacterPostCubit>().fetch();
  void changeCategory(
    BuildContext context,
    TagFilterCategory category,
  ) {
    final cubit = context.read<DanbooruArtistCharacterPostCubit>();
    cubit.changeCategory(category);
    cubit.refresh();
  }
}
