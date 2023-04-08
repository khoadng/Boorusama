// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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

typedef DanbooruPostState = PostState<DanbooruPostData, String>;

class DanbooruPostCubit extends PostCubit<DanbooruPostData, String>
    with DanbooruPostDataTransformMixin {
  DanbooruPostCubit({
    required String tags,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.favoritePostRepository,
    required this.currentBooruConfigRepository,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
  }) : super(initial: PostState.initial(tags));

  factory DanbooruPostCubit.of(
    BuildContext context, {
    required String tags,
  }) =>
      DanbooruPostCubit(
        tags: tags,
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
      (page) => postRepository.getPosts(state.extra, page).then(transform);

  @override
  Future<List<DanbooruPostData>> Function() get refresher =>
      () => postRepository.getPosts(state.extra, 1).then(transform);

  void setTags(String tags) => emit(state.copyWith(extra: tags));
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
