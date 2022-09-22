// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/accounts/accounts.dart';
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'common.dart';
import 'post_data.dart';

@immutable
class PostCuratedState extends Equatable {
  const PostCuratedState({
    required this.status,
    required this.posts,
    required this.filteredPosts,
    required this.page,
    required this.hasMore,
  });

  factory PostCuratedState.initial() => const PostCuratedState(
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

  PostCuratedState copyWith({
    LoadStatus? status,
    List<PostData>? posts,
    List<PostData>? filteredPosts,
    int? page,
    bool? hasMore,
  }) =>
      PostCuratedState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        filteredPosts: posts ?? this.posts,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  List<Object?> get props => [status, posts, filteredPosts, page, hasMore];
}

@immutable
abstract class PostCuratedEvent extends Equatable {
  const PostCuratedEvent();
}

class PostCuratedFetched extends PostCuratedEvent {
  const PostCuratedFetched({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [date, scale];
}

class PostCuratedRefreshed extends PostCuratedEvent {
  const PostCuratedRefreshed({
    required this.date,
    required this.scale,
  }) : super();

  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [];
}

class PostCuratedBloc extends Bloc<PostCuratedEvent, PostCuratedState> {
  PostCuratedBloc({
    required IPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required IFavoritePostRepository favoritePostRepository,
    required IAccountRepository accountRepository,
  }) : super(PostCuratedState.initial()) {
    on<PostCuratedFetched>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getCuratedPosts(
            event.date,
            state.page + 1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
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

    on<PostCuratedRefreshed>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getCuratedPosts(
            event.date,
            1,
            event.scale,
          ),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
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
}
