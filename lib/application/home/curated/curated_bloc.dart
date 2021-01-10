import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/post_dto.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/presentation/home/errors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

part 'curated_event.dart';
part 'curated_state.dart';
part 'curated_bloc.freezed.dart';

class CuratedBloc extends Bloc<CuratedEvent, CuratedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  CuratedBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(CuratedState.initial());

  @override
  Stream<CuratedState> mapEventToState(
    CuratedEvent event,
  ) async* {
    yield* event.map(
      started: (e) => _mapStartedToState(e),
      refreshed: (e) => _mapRefreshedToState(e),
      loadedMore: (e) => _mapLoadedMoreToState(e),
      timeChanged: (e) => _mapTimeChangedToState(e),
      timeScaleChanged: (e) => _mapTimeScaleChangedToState(e),
      timeForwarded: (e) => _mapTimeForwardedToState(e),
      timeBackwarded: (e) => _mapTimeBackwardedToState(e),
    );
  }

  Stream<CuratedState> _mapStartedToState(_Started event) async* {
    yield state.copyWith(
      isLoadingNew: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          state.selectedTime, state.page, state.selectedTimeScale);
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

  Stream<CuratedState> _mapRefreshedToState(_Refreshed event) async* {
    yield state.copyWith(
      page: 1,
      isRefreshing: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          state.selectedTime, state.page, state.selectedTimeScale);
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

  Stream<CuratedState> _mapLoadedMoreToState(_LoadedMore event) async* {
    final nextPage = state.page + 1;
    yield state.copyWith(
      page: nextPage,
      isLoadingMore: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          state.selectedTime, nextPage, state.selectedTimeScale);
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

  Stream<CuratedState> _mapTimeChangedToState(_TimeChanged event) async* {
    yield state.copyWith(
      selectedTime: event.date,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          event.date, state.page, state.selectedTimeScale);
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

  Stream<CuratedState> _mapTimeScaleChangedToState(
      _TimeScaleChanged event) async* {
    yield state.copyWith(
      selectedTimeScale: event.scale,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          state.selectedTime, state.page, event.scale);
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

  Stream<CuratedState> _mapTimeBackwardedToState(_TimeBackwarded event) async* {
    var previousDate;
    switch (state.selectedTimeScale) {
      case TimeScale.day:
        previousDate = Jiffy(state.selectedTime).subtract(days: 1);
        break;
      case TimeScale.week:
        previousDate = Jiffy(state.selectedTime).subtract(weeks: 1);
        break;
      case TimeScale.month:
        previousDate = Jiffy(state.selectedTime).subtract(months: 1);
        break;
      default:
        previousDate = Jiffy(state.selectedTime).subtract(days: 1);
        break;
    }

    yield state.copyWith(
      selectedTime: previousDate,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          previousDate, state.page, state.selectedTimeScale);
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

  Stream<CuratedState> _mapTimeForwardedToState(_TimeForwarded event) async* {
    var nextDate;
    switch (state.selectedTimeScale) {
      case TimeScale.day:
        nextDate = Jiffy(state.selectedTime).add(days: 1);
        break;
      case TimeScale.week:
        nextDate = Jiffy(state.selectedTime).add(weeks: 1);
        break;
      case TimeScale.month:
        nextDate = Jiffy(state.selectedTime).add(months: 1);
        break;
      default:
        nextDate = Jiffy(state.selectedTime).add(days: 1);
        break;
    }

    yield state.copyWith(
      selectedTime: nextDate,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getCuratedPosts(
          nextDate, state.page, state.selectedTimeScale);
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
