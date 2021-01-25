// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../post_filter.dart';

part 'latest_posts_state.dart';
part 'latest_posts_state_notifier.freezed.dart';

class LatestStateNotifier extends StateNotifier<LatestPostsState> {
  LatestStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(LatestPostsState.initial());

  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  Future<List<Post>> getMore() async {
    try {
      final nextPage = state.page + 1;
      state = state.copyWith(
        isLoadingMore: true,
      );

      final dtos = await _postRepository.getPosts(state.query, nextPage);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        isLoadingMore: false,
        posts: [...state.posts, ...filteredPosts],
        page: nextPage,
      );

      return filteredPosts;
    } on DatabaseTimeOut {
      return [];
    }
  }

  Future<List<Post>> refresh([String query = ""]) async {
    try {
      state = state.copyWith(
        isRefreshing: true,
        posts: [],
        query: query,
      );

      final dtos = await _postRepository.getPosts(query, 1);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        isRefreshing: false,
        posts: filteredPosts,
        page: 1,
      );
      return filteredPosts;
    } on DatabaseTimeOut {
      return [];
    }
  }
}

final latestPostsStateNotifierProvider =
    StateNotifierProvider<LatestStateNotifier>(
        (ref) => LatestStateNotifier(ref));

final _posts = Provider<List<Post>>(
    (ref) => ref.watch(latestPostsStateNotifierProvider.state).posts);

final latestPostsProvider = Provider<List<Post>>((ref) => ref.watch(_posts));

final _isLoadingMore = Provider<bool>(
    (ref) => ref.watch(latestPostsStateNotifierProvider.state).isLoadingMore);

final isLoadingMoreProvider =
    Provider<bool>((ref) => ref.watch(_isLoadingMore));

final _isRefreshing = Provider<bool>(
    (ref) => ref.watch(latestPostsStateNotifierProvider.state).isRefreshing);

final isRefreshingProvider = Provider<bool>((ref) => ref.watch(_isRefreshing));
