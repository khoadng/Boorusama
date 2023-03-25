// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/boorus.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/utils/bloc/bloc.dart';
import 'package:boorusama/utils/bloc/pagination_mixin.dart';

class PostBloc extends Bloc<PostEvent, PostState>
    with
        InfiniteLoadMixin<DanbooruPostData, PostState>,
        PaginationMixin<DanbooruPostData, PostState> {
  PostBloc({
    required DanbooruPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required FavoritePostRepository favoritePostRepository,
    required CurrentUserBooruRepository currentUserBooruRepository,
    required PostVoteRepository postVoteRepository,
    required PoolRepository poolRepository,
    double Function()? stateIdGenerator,
    List<DanbooruPostData>? initialData,
    PostPreviewPreloader? previewPreloader,
    bool? pagination,
    int? postsPerPage,
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
                .fetch(postRepository, page, limit: postsPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  currentUserBooruRepository,
                ))
                .then(filterWith(
                  blacklistedTagsRepository,
                  currentUserBooruRepository,
                ))
                .then(filterFlashFiles())
                .then(preloadPreviewImagesWith(previewPreloader)),
            onError: handleErrorWith(emit),
          );
        } else {
          await load(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            page: 1,
            fetch: (page) => event.fetcher
                .fetch(postRepository, page, limit: postsPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  currentUserBooruRepository,
                ))
                .then(filterWith(
                  blacklistedTagsRepository,
                  currentUserBooruRepository,
                ))
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
                .fetch(postRepository, page, limit: postsPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  currentUserBooruRepository,
                ))
                .then(filterWith(
                  blacklistedTagsRepository,
                  currentUserBooruRepository,
                ))
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
                .fetch(postRepository, page, limit: postsPerPage)
                .then(createPostDataWith(
                  favoritePostRepository,
                  postVoteRepository,
                  poolRepository,
                  currentUserBooruRepository,
                ))
                .then(filterWith(
                  blacklistedTagsRepository,
                  currentUserBooruRepository,
                ))
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

    on<PostRemoved>((event, emit) {
      final data = [...state.data]
        ..removeWhere((e) => event.postIds.contains(e.post.id));

      emit(state.copyWith(
        posts: data,
      ));
    });

    on<PostSwapped>((event, emit) {
      final data = [...state.data];
      final tmp = data[event.fromIndex];
      data[event.fromIndex] = data[event.toIndex];
      data[event.toIndex] = tmp;
      swap(event.fromIndex, event.toIndex);

      event.onSuccess?.call();

      emit(state.copyWith(
        posts: data,
      ));
    });

    on<PostMovedAndInserted>((event, emit) {
      final data = [...state.data];
      final item = data.removeAt(event.fromIndex);
      data.insert(event.toIndex, item);
      moveAndInsert(event.fromIndex, event.toIndex);

      event.onSuccess?.call();

      emit(state.copyWith(
        posts: data,
      ));
    });

    on<PostReset>((event, emit) {
      emit(PostState.initial());
    });

    data = initialData ?? [];
  }

  factory PostBloc.of(
    BuildContext context, {
    bool? pagination,
  }) =>
      PostBloc(
        postRepository: context.read<DanbooruPostRepository>(),
        blacklistedTagsRepository: context.read<BlacklistedTagsRepository>(),
        favoritePostRepository: context.read<FavoritePostRepository>(),
        postVoteRepository: context.read<PostVoteRepository>(),
        poolRepository: context.read<PoolRepository>(),
        previewPreloader: context.read<PostPreviewPreloader>(),
        pagination: pagination,
        postsPerPage: context.read<SettingsCubit>().state.settings.postsPerPage,
        currentUserBooruRepository: context.read<CurrentUserBooruRepository>(),
      );

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
          exceptionMessage: 'generic.errors.unknown',
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

Future<List<DanbooruPostData>> Function(List<DanbooruPostData> posts)
    filterFlashFiles() => filterUnsupportedFormat({'swf'});
