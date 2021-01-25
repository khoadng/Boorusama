// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../post_filter.dart';

part 'latest_posts_state.dart';
part 'latest_posts_state_notifier.freezed.dart';

final latestPostsStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>(
        (ref) => LatestStateNotifier(ref));

class LatestStateNotifier extends StateNotifier<LatestPostsState> {
  LatestStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(LatestPostsState.initial());

  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  void getMorePosts() async {
    try {
      final nextPage = state.page + 1;
      state = state.copyWith(
        postsState: PostState.loading(),
      );

      final dtos = await _postRepository.getPosts("", nextPage);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings)
        ..removeWhere((post) {
          final p = state.posts.firstWhere(
            (sPost) => sPost.id == post.id,
            orElse: () => null,
          );
          return p?.id == post.id;
        });

      state = state.copyWith(
        postsState: PostState.fetched(),
        posts: [...state.posts, ...filteredPosts],
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
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        posts: filteredPosts,
        postsState: PostState.fetched(),
      );
    } on DatabaseTimeOut {
      state = state.copyWith(
        postsState: PostState.error(),
      );
    }
  }
}
