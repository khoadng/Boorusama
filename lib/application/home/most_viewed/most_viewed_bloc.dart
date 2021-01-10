import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/presentation/home/errors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

part 'most_viewed_event.dart';
part 'most_viewed_state.dart';
part 'most_viewed_bloc.freezed.dart';

class MostViewedBloc extends Bloc<MostViewedEvent, MostViewedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  MostViewedBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(MostViewedState.initial());

  @override
  Stream<MostViewedState> mapEventToState(
    MostViewedEvent event,
  ) async* {
    yield* event.map(
      started: (e) => _mapStartedToState(e),
      refreshed: (e) => _mapRefreshedToState(e),
      timeChanged: (e) => _mapTimeChangedToState(e),
      timeForwarded: (e) => _mapTimeForwardedToState(e),
      timeBackwarded: (e) => _mapTimeBackwardedToState(e),
    );
  }

  Stream<MostViewedState> _mapStartedToState(_Started event) async* {
    yield state.copyWith(
      isLoadingNew: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getMostViewedPosts(state.selectedTime);
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

  Stream<MostViewedState> _mapRefreshedToState(_Refreshed event) async* {
    yield state.copyWith(
      isRefreshing: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getMostViewedPosts(state.selectedTime);
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

  Stream<MostViewedState> _mapTimeChangedToState(_TimeChanged event) async* {
    yield state.copyWith(
      selectedTime: event.date,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getMostViewedPosts(event.date);
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

  Stream<MostViewedState> _mapTimeBackwardedToState(
      _TimeBackwarded event) async* {
    final previousDate = Jiffy(state.selectedTime).subtract(days: 1);

    yield state.copyWith(
      selectedTime: previousDate,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getMostViewedPosts(previousDate);
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

  Stream<MostViewedState> _mapTimeForwardedToState(
      _TimeForwarded event) async* {
    final nextDate = Jiffy(state.selectedTime).add(days: 1);

    yield state.copyWith(
      selectedTime: nextDate,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getMostViewedPosts(nextDate);
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
