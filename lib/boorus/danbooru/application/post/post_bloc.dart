// Flutter imports:
import 'package:boorusama/boorus/danbooru/domain/accounts/i_account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/i_favorite_post_repository.dart';
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'common.dart';
import 'post_data.dart';

enum PostsOrder {
  popular,
  newest,
}

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

  final List<PostData> posts;
  final List<PostData> filteredPosts;
  final LoadStatus status;
  final int page;
  final bool hasMore;
  final String? exceptionMessage;

  PostState copyWith({
    LoadStatus? status,
    List<PostData>? posts,
    List<PostData>? filteredPosts,
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
    this.order,
  }) : super();
  final String tags;
  final PostsOrder? order;

  @override
  List<Object?> get props => [tags, order];
}

class PostRefreshed extends PostEvent {
  const PostRefreshed({
    this.tag,
    this.order,
  }) : super();

  final String? tag;
  final PostsOrder? order;

  @override
  List<Object?> get props => [tag, order];
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({
    required IPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required IFavoritePostRepository favoritePostRepository,
    required IAccountRepository accountRepository,
  }) : super(PostState.initial()) {
    on<PostFetched>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        final query = '${event.tags} ${_postsOrderToString(event.order)}';
        await tryAsync<List<Post>>(
          action: () => postRepository.getPosts(query, state.page + 1),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) => _emitError(error, emit),
          onSuccess: (posts) async {
            final postDatas = await createPostData(
                favoritePostRepository, posts, accountRepository);
            final filteredPosts = filterBlacklisted(postDatas, blacklisted);

            emit(
              state.copyWith(
                status: LoadStatus.success,
                posts: [
                  ...state.posts,
                  ...filter(postDatas, blacklisted),
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
        final query = '${event.tag ?? ''} ${_postsOrderToString(event.order)}';

        await tryAsync<List<Post>>(
          action: () => postRepository.getPosts(query, 1),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) => _emitError(error, emit),
          onSuccess: (posts) async {
            final postDatas = await createPostData(
                favoritePostRepository, posts, accountRepository);
            final filteredPosts = filterBlacklisted(postDatas, blacklisted);
            emit(
              state.copyWith(
                status: LoadStatus.success,
                posts: filter(postDatas, blacklisted),
                filteredPosts: filteredPosts,
                page: 1,
                hasMore: posts.isNotEmpty,
              ),
            );
          },
        );
      },
      transformer: restartable(),
    );
  }

  void _emitError(Object error, Emitter emit) {
    if (error is CannotSearchMoreThanTwoTags) {
      emit(state.copyWith(
        status: LoadStatus.failure,
        exceptionMessage: 'search.errors.tag_limit',
      ));
    } else if (error is DatabaseTimeOut) {
      emit(state.copyWith(
        status: LoadStatus.failure,
        exceptionMessage: 'search.errors.database_timeout',
      ));
    } else {
      emit(state.copyWith(
        status: LoadStatus.failure,
        exceptionMessage: 'search.errors.unknown',
      ));
    }
  }
}

String _postsOrderToString(PostsOrder? order) {
  switch (order) {
    case PostsOrder.popular:
      return 'order:favcount';
    default:
      return '';
  }
}
