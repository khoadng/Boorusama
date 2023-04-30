// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/post_vote_cubit.dart';
import 'package:boorusama/boorus/danbooru/application/posts/transformer.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/booru_user_identity_provider.dart';
import 'package:boorusama/core/application/posts.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/utils/collection_utils.dart';

mixin DanbooruFavoriteGroupPostCubitMixin<T extends StatefulWidget>
    on State<T> {
  Future<List<DanbooruPost>> refresh() =>
      context.read<DanbooruFavoriteGroupPostCubit>().refreshPost();

  Future<List<DanbooruPost>> fetch(int page) =>
      context.read<DanbooruFavoriteGroupPostCubit>().fetchPost(page);

  //FIXME: should move to widget page
  void moveAndInsert({
    required int fromIndex,
    required int toIndex,
    void Function()? onSuccess,
  }) =>
      context.read<DanbooruFavoriteGroupPostCubit>().moveAndInsert(
            fromIndex: fromIndex,
            toIndex: toIndex,
            onSuccess: onSuccess,
          );
  void remove(List<int> ids) =>
      context.read<DanbooruFavoriteGroupPostCubit>().remove(ids);
}

class DanbooruFavoriteGroupPostCubit with DanbooruPostTransformMixin {
  DanbooruFavoriteGroupPostCubit({
    required Queue<int> ids,
    required this.postRepository,
    required this.blacklistedTagsRepository,
    required this.currentBooruConfigRepository,
    required this.booruUserIdentityProvider,
    required this.postVoteRepository,
    required this.poolRepository,
    PostPreviewPreloader? previewPreloader,
    required this.favoriteCubit,
    required this.postVoteCubit,
  }) : _ids = ids;

  factory DanbooruFavoriteGroupPostCubit.of(
    BuildContext context, {
    required List<int> Function() ids,
  }) =>
      DanbooruFavoriteGroupPostCubit(
        ids: QueueList.from(ids()),
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
  Queue<int> _ids;

  Future<List<DanbooruPost>> Function(int page) get fetcher =>
      (page) => _fetch().then(transform);

  Future<List<DanbooruPost>> Function() get refresher =>
      () => _fetch().then(transform);

  Future<List<DanbooruPost>> refreshPost() async => refresher();
  Future<List<DanbooruPost>> fetchPost(int page) async => fetcher(page);

  void moveAndInsert({
    required int fromIndex,
    required int toIndex,
    void Function()? onSuccess,
  }) {
    // final data = [...state.data];
    // final item = data.removeAt(fromIndex);
    // data.insert(toIndex, item);
    // onSuccess?.call();

    // emit(state.copyWith(
    //   data: data,
    // ));
  }

  //FIXME: should move to widget page
  void remove(List<int> postIds) {
    // final data = [...state.data]..removeWhere((e) => postIds.contains(e.id));

    // emit(state.copyWith(
    //   data: data,
    // ));
  }

  Future<List<DanbooruPost>> _fetch() async {
    final ids = _ids.dequeue(20);

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
