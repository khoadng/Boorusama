// Dart imports:
import 'dart:collection';

// Flutter imports:
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
    List<Post>? posts,
    LoadStatus? status,
  }) =>
      PoolDetailState(
        posts: posts ?? this.posts,
        status: status ?? this.status,
      );

  final List<Post> posts;
  final LoadStatus status;

  @override
  List<Object?> get props => [posts, status];
}

class PoolDetailCubit extends Cubit<PoolDetailState> {
  PoolDetailCubit({
    required this.postRepository,
    required this.ids,
  }) : super(const PoolDetailState(
          posts: [],
          status: LoadStatus.initial,
        ));

  final IPostRepository postRepository;
  final Queue<int> ids;

  void load() {
    if (ids.isEmpty) return;
    tryAsync<List<Post>>(
      action: () => postRepository.getPostsFromIds(ids.dequeue(20)),
      onFailure: (stackTrace, error) =>
          emit(state.copyWith(status: LoadStatus.failure)),
      onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
      onSuccess: (posts) async {
        emit(state.copyWith(
            status: LoadStatus.success, posts: [...state.posts, ...posts]));
      },
    );
  }
}
