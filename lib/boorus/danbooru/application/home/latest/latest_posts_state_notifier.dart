// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';
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
  final listStateNotifier = ListStateNotifier<Post>();
  return LatestStateNotifier(removedNullImageRepo, listStateNotifier)
    ..refresh();
});

class LatestStateNotifier extends StateNotifier<LatestPostsState> {
  LatestStateNotifier(
      IPostRepository postRepository, ListStateNotifier<Post> listStateNotifier)
      : _postRepository = postRepository,
        _listStateNotifier = listStateNotifier,
        super(LatestPostsState.initial());

  final ListStateNotifier<Post> _listStateNotifier;
  final IPostRepository _postRepository;

  void getMorePosts() async {
    _listStateNotifier.getMoreItems(
      callback: () async {
        final nextPage = state.posts.page + 1;

        final dtos = await _postRepository.getPosts("", nextPage);
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        posts
          ..removeWhere((post) {
            final p = state.posts.items.firstWhere(
              (sPost) => sPost.id == post.id,
              orElse: () => null,
            );
            return p?.id == post.id;
          });

        return posts;
      },
      onStateChanged: (state) => this.state = this.state.copyWith(
            posts: state,
          ),
    );
  }

  void refresh() async {
    _listStateNotifier.refresh(
      callback: () async {
        final dtos = await _postRepository.getPosts("", 1);
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        return posts;
      },
      onStateChanged: (state) {
        if (mounted) {
          this.state = this.state.copyWith(
                posts: state,
              );
        }
      },
    );
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
