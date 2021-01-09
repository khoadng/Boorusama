import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'post_popular_event.dart';
part 'post_popular_state.dart';

part 'post_popular_bloc.freezed.dart';

class PostPopularBloc extends Bloc<PostPopularEvent, PostPopularState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  PostPopularBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(PostPopularState.empty());

  @override
  Stream<PostPopularState> mapEventToState(
    PostPopularEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
      moreRequested: (e) => _mapMoreRequestedToState(e),
    );
  }

  Stream<PostPopularState> _mapRequestedToState(_Requested event) async* {
    yield const PostPopularState.loading();
    final dtos = await _postRepository.getPopularPosts(
      event.date,
      event.page,
      event.scale,
    );

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

    yield PostPopularState.fetched(posts: filteredPosts);
  }

  Stream<PostPopularState> _mapMoreRequestedToState(
      _MoreRequested event) async* {
    yield const PostPopularState.additionalLoading();
    final dtos = await _postRepository.getPopularPosts(
      event.date,
      event.page,
      event.scale,
    );

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

    yield PostPopularState.additionalFetched(posts: filteredPosts);
  }
}
