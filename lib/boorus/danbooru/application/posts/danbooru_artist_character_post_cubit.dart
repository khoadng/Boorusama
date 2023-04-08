// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';

enum TagFilterCategory {
  popular,
  newest,
}

typedef DanbooruArtistCharacterPostState
    = PostState<DanbooruPostData, DanbooruArtistChararacterExtra>;

class DanbooruArtistChararacterExtra extends Equatable {
  final TagFilterCategory category;
  final String tag;

  DanbooruArtistChararacterExtra({
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
    extends PostCubit<DanbooruPostData, DanbooruArtistChararacterExtra>
    with DanbooruPostDataTransformMixin {
  DanbooruArtistCharacterPostCubit({
    required DanbooruArtistChararacterExtra extra,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.favoritePostRepository,
    required this.currentBooruConfigRepository,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
  }) : super(initial: PostState.initial(extra));

  factory DanbooruArtistCharacterPostCubit.of(
    BuildContext context, {
    required DanbooruArtistChararacterExtra extra,
  }) =>
      DanbooruArtistCharacterPostCubit(
        extra: extra,
        postRepository: context.read<DanbooruPostRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        favoritePostRepository: context.read<FavoritePostRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        currentBooruConfigRepository:
            context.read<CurrentBooruConfigRepository>(),
      );

  final DanbooruPostRepository postRepository;
  final BlacklistedTagsRepository blacklistedTagsRepository;
  final FavoritePostRepository favoritePostRepository;
  final CurrentBooruConfigRepository currentBooruConfigRepository;
  final PostVoteRepository postVoteRepository;
  final PoolRepository poolRepository;
  PostPreviewPreloader? previewPreloader;

  @override
  Future<List<DanbooruPostData>> Function(int page) get fetcher =>
      (page) => postRepository
          .getPosts(
            _extraToTagString(state.extra),
            page,
          )
          .then(transform);

  @override
  Future<List<DanbooruPostData>> Function() get refresher =>
      () => postRepository
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
