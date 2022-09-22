// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/common/collection_utils.dart';

@immutable
class PoolDetailState extends Equatable {
  const PoolDetailState({
    required this.posts,
    required this.status,
  });

  PoolDetailState copyWith({
    List<PostData>? posts,
    LoadStatus? status,
  }) =>
      PoolDetailState(
        posts: posts ?? this.posts,
        status: status ?? this.status,
      );

  final List<PostData> posts;
  final LoadStatus status;

  @override
  List<Object?> get props => [posts, status];
}

class PoolDetailCubit extends Cubit<PoolDetailState> {
  PoolDetailCubit({
    required this.postRepository,
    required this.favoritePostRepository,
    required this.accountRepository,
    required this.ids,
  }) : super(const PoolDetailState(
          posts: [],
          status: LoadStatus.initial,
        ));

  final IPostRepository postRepository;
  final IFavoritePostRepository favoritePostRepository;
  final IAccountRepository accountRepository;
  final Queue<int> ids;

  void load() {
    if (ids.isEmpty) return;
    tryAsync<List<Post>>(
      action: () => postRepository.getPostsFromIds(ids.dequeue(20)),
      onFailure: (stackTrace, error) =>
          emit(state.copyWith(status: LoadStatus.failure)),
      onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
      onSuccess: (posts) async {
        final postDatas = await createPostData(
          favoritePostRepository,
          posts,
          accountRepository,
        );
        emit(state.copyWith(
          status: LoadStatus.success,
          posts: [
            ...state.posts,
            ...postDatas,
          ],
        ));
      },
    );
  }
}
