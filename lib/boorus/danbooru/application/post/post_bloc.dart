// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/account_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorite_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/domain/error.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc({
    required PostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required FavoritePostRepository favoritePostRepository,
    required AccountRepository accountRepository,
    required PostVoteRepository postVoteRepository,
    required PoolRepository poolRepository,
    double Function()? stateIdGenerator,
  }) : super(PostState.initial()) {
    on<PostFetched>(
      (event, emit) async {
        await tryAsync<List<Post>>(
          action: () => event.fetcher.fetch(
            postRepository,
            state.page + 1,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) => _emitError(error, emit),
          onSuccess: (posts) async {
            try {
              final blacklisted =
                  await blacklistedTagsRepository.getBlacklistedTags();
              final postDatas = await createPostData(
                favoritePostRepository,
                postVoteRepository,
                poolRepository,
                posts,
                accountRepository,
              );
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
            } catch (e) {
              if (e is BooruError) {
                _emitError(e, emit);
              } else {
                _emitError(BooruError(error: e), emit);
              }
            }
          },
        );
      },
      transformer: droppable(),
    );

    on<PostRefreshed>(
      (event, emit) async {
        await tryAsync<List<Post>>(
          action: () => event.fetcher.fetch(
            postRepository,
            1,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) => _emitError(error, emit),
          onSuccess: (posts) async {
            try {
              final blacklisted =
                  await blacklistedTagsRepository.getBlacklistedTags();
              final postDatas = await createPostData(
                favoritePostRepository,
                postVoteRepository,
                poolRepository,
                posts,
                accountRepository,
              );
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
            } catch (e) {
              if (e is BooruError) {
                _emitError(e, emit);
              } else {
                _emitError(BooruError(error: e), emit);
              }
            }
          },
        );
      },
      transformer: restartable(),
    );

    on<PostFavoriteUpdated>((event, emit) {
      final index =
          state.posts.indexWhere((element) => element.post.id == event.postId);
      if (index > 0) {
        final posts = [...state.posts];
        posts[index] = state.posts[index].copyWith(
          isFavorited: event.favorite,
        );

        emit(
          state.copyWith(
            posts: posts,
          ),
        );
      }
    });

    on<PostUpdated>((event, emit) {
      final index =
          state.posts.indexWhere((element) => element.post.id == event.post.id);
      if (index > 0) {
        final posts = [...state.posts];
        posts[index] = state.posts[index].copyWith(
          post: event.post,
        );

        emit(
          state.copyWith(
            posts: posts,
            id: stateIdGenerator?.call() ?? Random().nextDouble(),
          ),
        );
      }
    });
  }

  factory PostBloc.of(BuildContext context) => PostBloc(
        postRepository: context.read<PostRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        favoritePostRepository: context.read<FavoritePostRepository>(),
        accountRepository: context.read<AccountRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
      );

  void _emitError(BooruError error, Emitter emit) {
    final failureState = state.copyWith(status: LoadStatus.failure);

    error.when(
      appError: (appError) => appError.when(
        cannotReachServer: () => failureState.copyWith(
          exceptionMessage: 'Cannot reach server, please check your connection',
        ),
        failedToParseJSON: () => failureState.copyWith(
          exceptionMessage:
              'Failed to parse data, please report this issue to the developer',
        ),
        unknown: () => failureState.copyWith(
          exceptionMessage: 'generic.errors.unknown',
        ),
      ),
      serverError: (error) {
        if (error.httpStatusCode == 422) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.tag_limit',
          ));
        } else if (error.httpStatusCode == 500) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.database_timeout',
          ));
        } else {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.unknown',
          ));
        }
      },
      unknownError: (_) {
        emit(failureState.copyWith(
          exceptionMessage: 'search.errors.unknown',
        ));
      },
    );
  }
}
