// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';

part 'latest_posts_state.dart';
part 'latest_posts_state_notifier.freezed.dart';

final latestPostsStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  return LatestStateNotifier(postRepo)..refresh();
});

class LatestStateNotifier extends StateNotifier<LatestPostsState> {
  LatestStateNotifier(IPostRepository postRepository)
      : _postRepository = postRepository,
        _listStateNotifier = ListStateNotifier<Post>(),
        super(LatestPostsState.initial());

  final ListStateNotifier<Post> _listStateNotifier;
  final IPostRepository _postRepository;

  void getMorePosts() async {
    _listStateNotifier.getMoreItems(
      callback: () async {
        final nextPage = state.posts.page + 1;

        final posts = await _postRepository.getPosts("", nextPage);

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
        final posts = await _postRepository.getPosts("", 1);

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
}
