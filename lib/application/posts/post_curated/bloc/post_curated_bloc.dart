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

part 'post_curated_event.dart';
part 'post_curated_state.dart';

part 'post_curated_bloc.freezed.dart';

class PostCuratedBloc extends Bloc<PostCuratedEvent, PostCuratedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  PostCuratedBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(PostCuratedState.empty());

  @override
  Stream<PostCuratedState> mapEventToState(
    PostCuratedEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
      moreRequested: (e) => _mapMoreRequestedToState(e),
    );
  }

  Stream<PostCuratedState> _mapRequestedToState(_Requested event) async* {
    yield const PostCuratedState.loading();
    final settings = await _settingRepository.load();
    final dtos = await _postRepository.getCuratedPosts(
      event.date,
      event.page,
      event.scale,
    );

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

    yield PostCuratedState.fetched(posts: filteredPosts);
  }

  Stream<PostCuratedState> _mapMoreRequestedToState(
      _MoreRequested event) async* {
    yield const PostCuratedState.additionalLoading();
    final settings = await _settingRepository.load();
    final dtos = await _postRepository.getCuratedPosts(
      event.date,
      event.page,
      event.scale,
    );

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
    yield PostCuratedState.additionalFetched(posts: filteredPosts);
  }
}
