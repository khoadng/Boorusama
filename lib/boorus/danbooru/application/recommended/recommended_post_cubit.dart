// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

@immutable
abstract class RecommendedPostEvent extends Equatable {
  const RecommendedPostEvent();
}

class RecommendedPostRequested extends RecommendedPostEvent {
  const RecommendedPostRequested({
    required this.tags,
  });
  final List<String> tags;
  @override
  List<Object?> get props => [tags];
}

class RecommendedPostBloc
    extends Bloc<RecommendedPostEvent, AsyncLoadState<List<Recommended>>> {
  RecommendedPostBloc({
    required IPostRepository postRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<RecommendedPostRequested>(
      (event, emit) async {
        await tryAsync<List<Recommended>>(
            action: () => Future.wait(
                    event.tags.where((tag) => tag.isNotEmpty).map((tag) async {
                  final posts = await postRepository.getPosts(tag, 1,
                      limit: 10, skipFavoriteCheck: true);

                  final recommended =
                      Recommended(title: tag, posts: posts.take(6).toList());

                  return recommended;
                }).toList()),
            onFailure: (stackTrace, error) =>
                emit(const AsyncLoadState.failure()),
            onLoading: () => emit(const AsyncLoadState.loading()),
            onSuccess: (posts) async => emit(AsyncLoadState.success(posts)));
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );
  }
}

class RecommendedArtistPostCubit extends RecommendedPostBloc {
  RecommendedArtistPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}

class RecommendedCharacterPostCubit extends RecommendedPostBloc {
  RecommendedCharacterPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}

class RecommendedPostCacher implements IPostRepository {
  const RecommendedPostCacher({
    required this.cache,
    required this.postRepository,
  });

  final Cacher cache;
  final IPostRepository postRepository;

  @override
  Future<List<Post>> getCuratedPosts(
          DateTime date, int page, TimeScale scale) =>
      postRepository.getCuratedPosts(date, page, scale);

  @override
  Future<List<Post>> getMostViewedPosts(DateTime date) =>
      postRepository.getMostViewedPosts(date);

  @override
  Future<List<Post>> getPopularPosts(
          DateTime date, int page, TimeScale scale) =>
      postRepository.getPopularPosts(date, page, scale);

  @override
  Future<List<Post>> getPosts(String tags, int page,
      {int limit = 50,
      CancelToken? cancelToken,
      bool skipFavoriteCheck = false}) async {
    final key = '$tags$page$limit';
    final posts = cache.get(key);

    if (posts != null) return posts;

    final fresh = await postRepository.getPosts(
      tags,
      page,
      limit: limit,
      cancelToken: cancelToken,
      skipFavoriteCheck: skipFavoriteCheck,
    );
    cache.put(key, fresh);

    return fresh;
  }

  @override
  Future<List<Post>> getPostsFromIds(List<int> ids) =>
      postRepository.getPostsFromIds(ids);
}
