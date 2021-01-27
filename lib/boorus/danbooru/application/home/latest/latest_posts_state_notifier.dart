// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../../black_listed_filter_decorator.dart';
import '../../no_image_filter_decorator.dart';

part 'latest_posts_state.dart';
part 'latest_posts_state_notifier.freezed.dart';

final latestPostsStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return LatestStateNotifier(removedNullImageRepo)..refresh();
});

class LatestStateNotifier extends StateNotifier<LatestPostsState> {
  LatestStateNotifier(IPostRepository postRepository)
      : _postRepository = postRepository,
        super(LatestPostsState.initial());

  final IPostRepository _postRepository;

  void getMorePosts() async {
    try {
      final nextPage = state.page + 1;
      state = state.copyWith(
        postsState: PostState.loading(),
      );

      final dtos = await _postRepository.getPosts("", nextPage);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      posts
        ..removeWhere((post) {
          final p = state.posts.firstWhere(
            (sPost) => sPost.id == post.id,
            orElse: () => null,
          );
          return p?.id == post.id;
        });

      state = state.copyWith(
        postsState: PostState.fetched(),
        posts: [...state.posts, ...posts],
        page: nextPage,
      );
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }

  void refresh() async {
    try {
      state = state.copyWith(
        page: 1,
        posts: [],
        postsState: PostState.refreshing(),
      );

      final dtos = await _postRepository.getPosts("", state.page);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      //TODO: workaround, cause Bad state error somehow...
      if (mounted) {
        state = state.copyWith(
          posts: posts,
          postsState: PostState.fetched(),
        );
      }
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }

  void viewPost(Post post) {
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: post,
    );
  }

  void stopViewing() {
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: null,
    );
  }
}
