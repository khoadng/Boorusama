import 'dart:async';

import 'package:boorusama/domain/posts/posts.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'browse_all_state.dart';
part 'browse_all_state_notifier.freezed.dart';

class BrowseAllStateNotifier extends StateNotifier<BrowseAllState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  BrowseAllStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(BrowseAllState.initial());

  void getPosts(String query, int page) async {
    try {
      state = BrowseAllState.loading();

      final dtos = await _postRepository.getPosts(query, 1);
      final filteredPosts = await _loadFromDtos(dtos);

      state = BrowseAllState.fetched(
        posts: filteredPosts,
        page: page,
        query: query,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void refresh() async {
    try {
      state = BrowseAllState.loading();

      final dtos = await _postRepository.getPosts("", 1);
      final filteredPosts = await _loadFromDtos(dtos);

      state = BrowseAllState.fetched(
        posts: filteredPosts,
        page: 1,
        query: "",
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void getMorePosts(List<Post> currentPosts, String query, int page) async {
    try {
      final nextPage = page + 1;
      final dtos = await _postRepository.getPosts(query, nextPage);
      final filteredPosts = await _loadFromDtos(dtos);

      state = BrowseAllState.fetched(
        posts: currentPosts..addAll(filteredPosts),
        page: nextPage,
        query: query,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  // @override
  // Stream<BrowseAllState> mapEventToState(
  //   BrowseAllEvent event,
  // ) async* {
  //   yield* event.map(
  //     started: (e) => _mapStartedToState(e),
  //     refreshed: (e) => _mapRefreshedToState(e),
  //     loadedMore: (e) => _mapLoadedMoreToState(e),
  //     searched: (e) => _mapSearchedToState(e),
  //   );
  // }

  // Stream<BrowseAllState> _mapStartedToState(_Started event) async* {
  //   final query = event.initialQuery ?? "";
  //   yield state.copyWith(
  //     query: query,
  //     page: 1,
  //     isLoadingNew: true,
  //     error: null,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPosts(query, 1);
  //     final filteredPosts = await _loadFromDtos(dtos);

  //     yield state.copyWith(
  //       isLoadingNew: false,
  //       posts: filteredPosts,
  //     );
  //   } on DatabaseTimeOut catch (e) {
  //     yield state.copyWith(
  //       error: Error(name: "Search Timeout", message: e.message),
  //     );
  //   }
  // }

  // Stream<BrowseAllState> _mapRefreshedToState(_Refreshed event) async* {
  //   yield state.copyWith(
  //     query: state.query,
  //     page: 1,
  //     isRefreshing: true,
  //     error: null,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPosts(state.query, 1);
  //     final filteredPosts = await _loadFromDtos(dtos);

  //     yield state.copyWith(
  //       isRefreshing: false,
  //       posts: filteredPosts,
  //     );
  //   } on DatabaseTimeOut catch (e) {
  //     yield state.copyWith(
  //       error: Error(name: "Search Timeout", message: e.message),
  //     );
  //   }
  // }

  // Stream<BrowseAllState> _mapLoadedMoreToState(_LoadedMore event) async* {
  //   final nextPage = state.page + 1;
  //   yield state.copyWith(
  //     query: state.query,
  //     page: nextPage,
  //     isLoadingMore: true,
  //     error: null,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPosts(state.query, nextPage);
  //     final filteredPosts = await _loadFromDtos(dtos);

  //     yield state.copyWith(
  //       isLoadingMore: false,
  //       posts: state.posts..addAll(filteredPosts),
  //     );
  //   } on DatabaseTimeOut catch (e) {
  //     yield state.copyWith(
  //       error: Error(name: "Search Timeout", message: e.message),
  //     );
  //   }
  // }

  // Stream<BrowseAllState> _mapSearchedToState(_Searched event) async* {
  //   yield state.copyWith(
  //     query: event.query,
  //     page: 1,
  //     isSearching: true,
  //     error: null,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPosts(event.query, 1);
  //     final filteredPosts = await _loadFromDtos(dtos);

  //     yield state.copyWith(
  //       isSearching: false,
  //       posts: filteredPosts,
  //     );
  //   } on CannotSearchMoreThanTwoTags catch (e) {
  //     yield state.copyWith(
  //       error: Error(name: "Search Error", message: e.message),
  //     );
  //   } on DatabaseTimeOut catch (e) {
  //     yield state.copyWith(
  //       error: Error(name: "Search Timeout", message: e.message),
  //     );
  //   }
  // }

  Future<List<Post>> _loadFromDtos(List<PostDto> dtos) async {
    final settings = await _settingRepository.load();
    final posts = <Post>[];
    dtos.forEach((dto) {
      if (dto.file_url != null &&
          dto.preview_file_url != null &&
          dto.large_file_url != null) {
        posts.add(dto.toEntity());
      }
    });

    final filteredPosts = posts
        .where((post) => !post.containsBlacklistedTag(settings.blacklistedTags))
        .toList();
    return filteredPosts;
  }
}
