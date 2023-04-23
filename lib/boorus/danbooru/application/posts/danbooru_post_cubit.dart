// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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

typedef DanbooruPostState = PostState<DanbooruPost, DanbooruPostExtra>;

class DanbooruPostExtra extends Equatable {
  final String tag;
  final int? limit;

  const DanbooruPostExtra({
    required this.tag,
    this.limit,
  });

  @override
  List<Object?> get props => [tag, limit];

  DanbooruPostExtra copyWith({
    String? tag,
    int? Function()? limit,
  }) {
    return DanbooruPostExtra(
      tag: tag ?? this.tag,
      limit: limit != null ? limit() : this.limit,
    );
  }
}

class DanbooruPostCubit extends PostCubit<DanbooruPost, DanbooruPostExtra>
    with DanbooruPostTransformMixin {
  DanbooruPostCubit({
    required DanbooruPostExtra extra,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.currentBooruConfigRepository,
    required this.booruUserIdentityProvider,
    required this.postVoteRepository,
    required this.poolRepository,
    required this.favoriteCubit,
    required this.postVoteCubit,
    PostPreviewPreloader? previewPreloader,
  }) : super(initial: PostState.initial(extra));

  factory DanbooruPostCubit.of(
    BuildContext context, {
    required DanbooruPostExtra extra,
  }) =>
      DanbooruPostCubit(
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
            state.extra.tag,
            page,
            limit: state.extra.limit,
          )
          .then(transform);

  @override
  Future<List<DanbooruPost>> Function() get refresher => () => postRepository
      .getPosts(
        state.extra.tag,
        1,
        limit: state.extra.limit,
      )
      .then(transform);

  void setTags(String tags) => emit(state.copyWith(
        extra: state.extra.copyWith(tag: tags),
      ));
}

mixin DanbooruPostCubitMixin<T extends StatefulWidget> on State<T> {
  void refresh() => context.read<DanbooruPostCubit>().refresh();
  void fetch() => context.read<DanbooruPostCubit>().fetch();
}

mixin DanbooruPostCubitStatelessMixin on StatelessWidget {
  void refresh(BuildContext context) =>
      context.read<DanbooruPostCubit>().refresh();
  void fetch(BuildContext context) => context.read<DanbooruPostCubit>().fetch();
}
