import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/presentation/home/views/browse_all/errors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'browse_all_event.dart';
part 'browse_all_state.dart';
part 'browse_all_bloc.freezed.dart';

class BrowseAllBloc extends Bloc<BrowseAllEvent, BrowseAllState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  BrowseAllBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(BrowseAllState.initial());

  @override
  Stream<BrowseAllState> mapEventToState(
    BrowseAllEvent event,
  ) async* {
    yield* event.map(
      started: (e) => _mapStartedToState(e),
      refreshed: (e) => _mapRefreshedToState(e),
      loadedMore: (e) => _mapLoadedMoreToState(e),
      searched: (e) => _mapSearchedToState(e),
    );
  }

  Stream<BrowseAllState> _mapStartedToState(_Started event) async* {
    final query = event.initialQuery ?? "";
    yield state.copyWith(
      query: query,
      page: 1,
      isLoadingNew: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPosts(query, 1);
      final filteredPosts = await _loadFromDtos(dtos);

      yield state.copyWith(
        isLoadingNew: false,
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {
      yield state.copyWith(
        error: Error(name: "Search Timeout", message: e.message),
      );
    }
  }

  Stream<BrowseAllState> _mapRefreshedToState(_Refreshed event) async* {
    yield state.copyWith(
      query: state.query,
      page: 1,
      isRefreshing: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPosts(state.query, 1);
      final filteredPosts = await _loadFromDtos(dtos);

      yield state.copyWith(
        isRefreshing: false,
        posts: filteredPosts,
      );
    } on DatabaseTimeOut catch (e) {
      yield state.copyWith(
        error: Error(name: "Search Timeout", message: e.message),
      );
    }
  }

  Stream<BrowseAllState> _mapLoadedMoreToState(_LoadedMore event) async* {
    final nextPage = state.page + 1;
    yield state.copyWith(
      query: state.query,
      page: nextPage,
      isLoadingMore: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPosts(state.query, nextPage);
      final filteredPosts = await _loadFromDtos(dtos);

      yield state.copyWith(
        isLoadingMore: false,
        posts: state.posts..addAll(filteredPosts),
      );
    } on DatabaseTimeOut catch (e) {
      yield state.copyWith(
        error: Error(name: "Search Timeout", message: e.message),
      );
    }
  }

  Stream<BrowseAllState> _mapSearchedToState(_Searched event) async* {
    yield state.copyWith(
      query: event.query,
      page: 1,
      isSearching: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPosts(event.query, 1);
      final filteredPosts = await _loadFromDtos(dtos);

      yield state.copyWith(
        isSearching: false,
        posts: filteredPosts,
      );
    } on CannotSearchMoreThanTwoTags catch (e) {
      yield state.copyWith(
        error: Error(name: "Search Error", message: e.message),
      );
    } on DatabaseTimeOut catch (e) {
      yield state.copyWith(
        error: Error(name: "Search Timeout", message: e.message),
      );
    }
  }

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
