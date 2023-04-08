// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts/transformer.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/utils/collection_utils.dart';

mixin DanbooruFavoriteGroupPostCubitMixin<T extends StatefulWidget>
    on State<T> {
  void refresh() => context.read<DanbooruFavoriteGroupPostCubit>().refresh();
  void fetch() => context.read<DanbooruFavoriteGroupPostCubit>().fetch();
}

class DanbooruFavoriteGroupPostCubit extends PostCubit<DanbooruPostData, String>
    with DanbooruPostDataTransformMixin {
  DanbooruFavoriteGroupPostCubit({
    required Queue<int> Function() ids,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.favoritePostRepository,
    required this.currentBooruConfigRepository,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
  })  : _ids = ids,
        super(initial: PostState.initial(""));

  factory DanbooruFavoriteGroupPostCubit.of(
    BuildContext context, {
    required List<int> Function() ids,
  }) =>
      DanbooruFavoriteGroupPostCubit(
        ids: () => QueueList.from(ids()),
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
  Queue<int> Function() _ids;

  @override
  Future<List<DanbooruPostData>> Function(int page) get fetcher =>
      (page) => _fetch(page).then(transform);

  @override
  Future<List<DanbooruPostData>> Function() get refresher =>
      () => _fetch(1).then(transform);

  Future<List<DanbooruPost>> _fetch(
    int page, {
    int? limit,
  }) async {
    final ids = _ids().dequeue(20);
    final posts = await postRepository.getPostsFromIds(
      ids,
    );

    final orderMap = <int, int>{};
    for (var index = 0; index < ids.length; index++) {
      orderMap[ids[index]] = index;
    }

    final orderedPosts = posts
        .where((e) => orderMap.containsKey(e.id))
        .map((e) => _Payload(orderMap[e.id]!, e))
        .sorted();

    return orderedPosts.map((e) => e.post).toList();
  }
}

class _Payload implements Comparable<_Payload> {
  _Payload(this.order, this.post);

  final DanbooruPost post;
  final int order;

  @override
  int compareTo(_Payload other) {
    if (other.order < order) return 1;
    if (other.order > order) return -1;

    return 0;
  }
}
