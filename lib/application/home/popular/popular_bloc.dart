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

part 'popular_event.dart';
part 'popular_state.dart';
part 'popular_bloc.freezed.dart';

class PopularBloc extends Bloc<PopularEvent, PopularState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  PopularBloc({
    @required IPostRepository postRepository,
    @required ISettingRepository settingRepository,
  })  : _postRepository = postRepository,
        _settingRepository = settingRepository,
        super(PopularState.initial());

  @override
  Stream<PopularState> mapEventToState(
    PopularEvent event,
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

  Stream<PopularState> _mapStartedToState(_Started event) async* {
    yield state.copyWith(
      isLoadingNew: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapRefreshedToState(_Refreshed event) async* {
    yield state.copyWith(
      page: 1,
      isRefreshing: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapLoadedMoreToState(_LoadedMore event) async* {
    final nextPage = state.page + 1;
    yield state.copyWith(
      page: nextPage,
      isLoadingMore: true,
      error: null,
    );

    try {
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapTimeChangedToState(_TimeChanged event) async* {
    yield state.copyWith(
      selectedTime: event.date,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapTimeScaleChangedToState(
      _TimeScaleChanged event) async* {
    yield state.copyWith(
      selectedTimeScale: event.scale,
      isLoadingNew: true,
    );

    try {
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapTimeBackwardedToState(_TimeBackwarded event) async* {
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
      final dtos = await _postRepository.getPopularPosts(
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

  Stream<PopularState> _mapTimeForwardedToState(_TimeForwarded event) async* {
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
      final dtos = await _postRepository.getPopularPosts(
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
