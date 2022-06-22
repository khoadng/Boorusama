// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/repositories.dart';
import 'package:boorusama/core/application/exception.dart';
import 'package:boorusama/main.dart';
import 'common.dart';

@immutable
class PostState extends Equatable {
  const PostState({
    required this.status,
    required this.posts,
    required this.filteredPosts,
    required this.page,
    required this.hasMore,
    this.exceptionMessage,
  });

  factory PostState.initial() => const PostState(
        status: LoadStatus.initial,
        posts: [],
        filteredPosts: [],
        page: 1,
        hasMore: true,
      );

  final List<Post> posts;
  final List<Post> filteredPosts;
  final LoadStatus status;
  final int page;
  final bool hasMore;
  final String? exceptionMessage;

  PostState copyWith({
    LoadStatus? status,
    List<Post>? posts,
    List<Post>? filteredPosts,
    int? page,
    bool? hasMore,
    String? exceptionMessage,
  }) =>
      PostState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        exceptionMessage: exceptionMessage ?? this.exceptionMessage,
      );

  @override
  List<Object?> get props =>
      [status, posts, filteredPosts, page, hasMore, exceptionMessage];
}

@immutable
abstract class PostEvent extends Equatable {
  const PostEvent();
}

class PostFetched extends PostEvent {
  const PostFetched({
    required this.tags,
  }) : super();
  final String tags;

  @override
  List<Object?> get props => [tags];
}

class PostRefreshed extends PostEvent {
  const PostRefreshed({
    this.tag,
  }) : super();

  final String? tag;

  @override
  List<Object?> get props => [tag];
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({
    required IPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
  }) : super(PostState.initial()) {
    on<PostFetched>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getPosts(event.tags, state.page + 1),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) {
            if (error is CannotSearchMoreThanTwoTags) {
              emit(state.copyWith(
                status: LoadStatus.failure,
                exceptionMessage: error.message,
              ));
            } else {
              emit(state.copyWith(
                status: LoadStatus.failure,
                exceptionMessage:
                    'Unknown exception has occured, please try again later',
              ));
            }
          },
          onSuccess: (posts) async {
            final filteredPosts = filterBlacklisted(posts, blacklisted);
            // print(
            //     '${filteredPosts.length} posts got filtered. Total: ${state.filteredPosts.length + filteredPosts.length}');
            emit(
              state.copyWith(
                status: LoadStatus.success,
                posts: [
                  ...state.posts,
                  ...filter(posts, blacklisted),
                ],
                filteredPosts: [
                  ...state.filteredPosts,
                  ...filteredPosts,
                ],
                page: state.page + 1,
                hasMore: posts.isNotEmpty,
              ),
            );
          },
        );
      },
      transformer: droppable(),
    );

    on<PostRefreshed>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getPosts(event.tag ?? '', 1),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) {
            if (error is BooruException) {
              emit(state.copyWith(
                status: LoadStatus.failure,
                exceptionMessage: error.message,
              ));
            } else {
              emit(state.copyWith(
                status: LoadStatus.failure,
                exceptionMessage:
                    'Unknown exception has occured, please try again later',
              ));
            }
          },
          onSuccess: (posts) async => emit(
            state.copyWith(
              status: LoadStatus.success,
              posts: filter(posts, blacklisted),
              filteredPosts: filterBlacklisted(posts, blacklisted),
              page: 1,
              hasMore: posts.isNotEmpty,
            ),
          ),
        );
      },
      transformer: restartable(),
    );
  }
}
