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
import 'package:boorusama/common/bloc/bloc.dart';
import 'package:boorusama/common/bloc/pagination_mixin.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts/post_preloader.dart';

class PostBloc extends Bloc<PostEvent, PostState>
    with
        InfiniteLoadMixin<PostData, PostState>,
        PaginationMixin<PostData, PostState> {
  PostBloc({
    required PostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required FavoritePostRepository favoritePostRepository,
    required AccountRepository accountRepository,
    required PostVoteRepository postVoteRepository,
    required PoolRepository poolRepository,
    double Function()? stateIdGenerator,
    List<PostData>? initialData,
    PostPreviewPreloader? previewPreloader,
    bool singleRefresh = false,
    bool? pagination,
  }) : super(PostState.initial(pagination: pagination)) {
    on<PostRefreshed>(
      (event, emit) async {
        if (!state.pagination) {
          await refresh(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            refresh: (page) => event.fetcher
                .fetch(postRepository, page, limit: singleRefresh ? null : 20)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  accountRepository,
                ))
                .then(filterWith(blacklistedTagsRepository))
                .then(filterFlashFiles())
                .then(preloadPreviewImagesWith(previewPreloader)),
            onError: handleErrorWith(emit),
          );

          if (!singleRefresh) {
            for (var i = 0; i < 2; i++) {
              await fetch(
                emit: EmitConfig(
                  stateGetter: () => state,
                  emitter: emit,
                ),
                fetch: (page) => event.fetcher
                    .fetch(postRepository, page, limit: 20)
                    .then(createPostDataWith(
                      favoritePostRepository,
                      postVoteRepository,
                      poolRepository,
                      accountRepository,
                    ))
                    .then(filterWith(blacklistedTagsRepository))
                    .then(filterFlashFiles())
                    .then(preloadPreviewImagesWith(previewPreloader)),
                onError: handleErrorWith(emit),
              );
            }
          }
        } else {
          await load(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            page: 1,
            fetch: (page) => event.fetcher
                .fetch(postRepository, page, limit: postPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  accountRepository,
                ))
                .then(filterWith(blacklistedTagsRepository))
                .then(filterFlashFiles())
                .then(preloadPreviewImagesWith(previewPreloader)),
            onError: handleErrorWith(emit),
          );
        }
      },
      transformer: restartable(),
    );

    on<PostFetched>(
      (event, emit) async {
        if (!state.pagination) {
          await fetch(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            fetch: (page) => event.fetcher
                .fetch(postRepository, page)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  accountRepository,
                ))
                .then(filterWith(blacklistedTagsRepository))
                .then(filterFlashFiles())
                .then(preloadPreviewImagesWith(previewPreloader)),
            onError: handleErrorWith(emit),
          );
        } else {
          if (event.page == null) return;

          await load(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            page: event.page!,
            fetch: (page) => event.fetcher
                .fetch(postRepository, page, limit: postPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  accountRepository,
                ))
                .then(filterWith(blacklistedTagsRepository))
                .then(filterFlashFiles())
                .then(preloadPreviewImagesWith(previewPreloader)),
            onError: handleErrorWith(emit),
          );
        }
      },
      transformer: droppable(),
    );

    on<PostFavoriteUpdated>((event, emit) {
      final index =
          state.posts.indexWhere((element) => element.post.id == event.postId);
      if (index >= 0) {
        final posts = [...state.posts];
        posts[index] = state.posts[index].copyWith(
          isFavorited: event.favorite,
        );

        replaceAt(index, posts[index]);

        emit(
          state.copyWith(
            posts: posts,
          ),
        );
      }
    });

    on<PostUpdated>((event, emit) {
      final index = state.posts
          .indexWhere((element) => element.post.id == event.post.post.id);
      if (index >= 0) {
        final posts = [...state.posts];
        posts[index] = event.post;

        replaceAt(index, posts[index]);

        emit(
          state.copyWith(
            posts: posts,
            id: stateIdGenerator?.call() ?? Random().nextDouble(),
          ),
        );
      }
    });

    on<PostReset>((event, emit) {
      emit(PostState.initial());
    });

    data = initialData ?? [];
  }

  factory PostBloc.of(
    BuildContext context, {
    bool? pagination,
    bool? singleRefresh,
  }) =>
      PostBloc(
        postRepository: context.read<PostRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        favoritePostRepository: context.read<FavoritePostRepository>(),
        accountRepository: context.read<AccountRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        pagination: pagination,
        singleRefresh: singleRefresh ?? false,
      );

  static const postPerPage = 60;

  void Function(Object error, StackTrace stackTrace) handleErrorWith(
    Emitter emit,
  ) =>
      (error, stackTrace) => error is BooruError
          ? _emitError(error, emit)
          : _emitError(BooruError(error: error), emit);

  void _emitError(BooruError error, Emitter emit) {
    final failureState = state.copyWith(
      status: LoadStatus.failure,
      error: error,
    );

    error.when(
      appError: (appError) => appError.when(
        cannotReachServer: () => emit(failureState.copyWith(
          exceptionMessage: 'Cannot reach server, please check your connection',
        )),
        failedToParseJSON: () => emit(failureState.copyWith(
          exceptionMessage:
              'Failed to parse data, please report this issue to the developer',
        )),
        unknown: () => emit(
          failureState.copyWith(
            exceptionMessage: 'generic.errors.unknown',
          ),
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
        } else if (error.httpStatusCode == 429) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.rate_limited',
          ));
        } else if (error.httpStatusCode == 410) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.pagination_limit',
          ));
        } else if (error.httpStatusCode == 403) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.access_denied',
          ));
        } else if (error.httpStatusCode == 401) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.forbidden',
          ));
        } else if (error.httpStatusCode == 502) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.max_capacity',
          ));
        } else if (error.httpStatusCode == 503) {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.down',
          ));
        } else {
          emit(failureState.copyWith(
            exceptionMessage: 'search.errors.unknown',
          ));
        }
      },
      unknownError: (error) {
        emit(failureState.copyWith(
          exceptionMessage: 'generic.errors.unknown\n\n${error.toString()}',
        ));
      },
    );
  }
}

String? getErrorMessage(BooruError error) {
  String? message;

  error.when(
    serverError: (error) {
      if (error.httpStatusCode == 422) {
        message = 'search.errors.tag_limit';
      } else if (error.httpStatusCode == 500) {
        message = 'search.errors.database_timeout';
      } else {
        message = 'search.errors.unknown';
      }
    },
    unknownError: (_) {
      message = 'search.errors.unknown';
    },
    appError: (AppError error) => message = null,
  );

  return message;
}

Future<List<PostData>> Function(List<PostData> posts) filterFlashFiles() =>
    filterUnsupportedFormat({'swf'});
