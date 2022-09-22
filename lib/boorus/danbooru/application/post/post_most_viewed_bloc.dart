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
class PostMostViewedState extends Equatable {
  const PostMostViewedState({
    required this.status,
    required this.posts,
    required this.filteredPosts,
    required this.hasMore,
  });

  factory PostMostViewedState.initial() => const PostMostViewedState(
        status: LoadStatus.initial,
        posts: [],
        filteredPosts: [],
        hasMore: true,
      );

  final List<PostData> posts;
  final List<PostData> filteredPosts;
  final LoadStatus status;
  final bool hasMore;

  PostMostViewedState copyWith({
    LoadStatus? status,
    List<PostData>? posts,
    List<PostData>? filteredPosts,
    bool? hasMore,
  }) =>
      PostMostViewedState(
        status: status ?? this.status,
        posts: posts ?? this.posts,
        filteredPosts: filteredPosts ?? this.filteredPosts,
        hasMore: hasMore ?? this.hasMore,
      );

  @override
  List<Object?> get props => [status, posts, filteredPosts, hasMore];
}

@immutable
abstract class PostMostViewedEvent extends Equatable {
  const PostMostViewedEvent();
}

class PostMostViewedFetched extends PostMostViewedEvent {
  const PostMostViewedFetched({
    required this.date,
  }) : super();

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class PostMostViewedRefreshed extends PostMostViewedEvent {
  const PostMostViewedRefreshed({
    required this.date,
  }) : super();

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class PostMostViewedBloc
    extends Bloc<PostMostViewedEvent, PostMostViewedState> {
  PostMostViewedBloc({
    required IPostRepository postRepository,
    required BlacklistedTagsRepository blacklistedTagsRepository,
    required IFavoritePostRepository favoritePostRepository,
    required IAccountRepository accountRepository,
  }) : super(PostMostViewedState.initial()) {
    on<PostMostViewedFetched>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getMostViewedPosts(
            event.date,
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
                hasMore: false,
              ),
            );
          },
        );
      },
      transformer: droppable(),
    );

    on<PostMostViewedRefreshed>(
      (event, emit) async {
        final blacklisted =
            await blacklistedTagsRepository.getBlacklistedTags();
        await tryAsync<List<Post>>(
          action: () => postRepository.getMostViewedPosts(
            event.date,
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
                hasMore: false,
              ),
            );
          },
        );
      },
      transformer: restartable(),
    );
  }
}
