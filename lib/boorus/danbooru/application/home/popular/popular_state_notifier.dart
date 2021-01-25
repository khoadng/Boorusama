// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../post_filter.dart';

part 'popular_state.dart';
part 'popular_state_notifier.freezed.dart';

final popularStateNotifierProvider =
    StateNotifierProvider<PopularStateNotifier>((ref) {
  return PopularStateNotifier(ref)..refresh();
});

class PopularStateNotifier extends StateNotifier<PopularState> {
  PopularStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider.future),
        super(PopularState.initial());

  final IPostRepository _postRepository;
  final Future<ISettingRepository> _settingRepository;

  void getMorePosts() async {
    try {
      final nextPage = state.page + 1;
      state = state.copyWith(
        postsState: PostState.loading(),
      );

      final dtos = await _postRepository.getPopularPosts(
          state.selectedDate, nextPage, state.selectedTimeScale);
      final settingsRepo = await _settingRepository;
      final settings = await settingsRepo.load();
      final filteredPosts = filter(dtos, settings);

      state = state.copyWith(
        posts: [...filteredPosts, ...state.posts],
        postsState: PostState.fetched(),
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

      final dtos = await _postRepository.getPopularPosts(
          state.selectedDate, state.page, state.selectedTimeScale);
      final settingsRepo = await _settingRepository;
      final settings = await settingsRepo.load();
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

  void forwardOneTimeUnit() {
    DateTime nextDate;

    switch (state.selectedTimeScale) {
      case TimeScale.day:
        nextDate = Jiffy(state.selectedDate).add(days: 1);
        break;
      case TimeScale.week:
        nextDate = Jiffy(state.selectedDate).add(weeks: 1);
        break;
      case TimeScale.month:
        nextDate = Jiffy(state.selectedDate).add(months: 1);
        break;
      default:
        nextDate = Jiffy(state.selectedDate).add(days: 1);
        break;
    }

    state = state.copyWith(
      selectedDate: nextDate,
    );
  }

  void reverseOneTimeUnit() {
    DateTime previous;

    switch (state.selectedTimeScale) {
      case TimeScale.day:
        previous = Jiffy(state.selectedDate).subtract(days: 1);
        break;
      case TimeScale.week:
        previous = Jiffy(state.selectedDate).subtract(weeks: 1);
        break;
      case TimeScale.month:
        previous = Jiffy(state.selectedDate).subtract(months: 1);
        break;
      default:
        previous = Jiffy(state.selectedDate).subtract(days: 1);
        break;
    }

    state = state.copyWith(
      selectedDate: previous,
    );
  }

  void updateTimeScale(TimeScale timeScale) {
    state = state.copyWith(
      selectedTimeScale: timeScale,
    );
  }

  void updateDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
    );
  }
}
