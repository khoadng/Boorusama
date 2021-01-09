import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'post_most_viewed_event.dart';
part 'post_most_viewed_state.dart';

part 'post_most_viewed_bloc.freezed.dart';

class PostMostViewedBloc
    extends Bloc<PostMostViewedEvent, PostMostViewedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  PostMostViewedBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(PostMostViewedState.empty());

  @override
  Stream<PostMostViewedState> mapEventToState(
    PostMostViewedEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
      moreRequested: (e) => _mapMoreRequestedToState(e),
    );
  }

  Stream<PostMostViewedState> _mapRequestedToState(_Requested event) async* {
    yield const PostMostViewedState.loading();
    final dtos = await _postRepository.getMostViewedPosts(
      event.date,
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

    yield PostMostViewedState.fetched(posts: filteredPosts);
  }

  Stream<PostMostViewedState> _mapMoreRequestedToState(
      _MoreRequested event) async* {
    yield const PostMostViewedState.additionalLoading();
    final dtos = await _postRepository.getMostViewedPosts(
      event.date,
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

    yield PostMostViewedState.additionalFetched(posts: filteredPosts);
  }
}
