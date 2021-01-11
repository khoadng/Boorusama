import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../post_filter.dart';

part 'popular_state.dart';
part 'popular_state_notifier.freezed.dart';

class PopularStateNotifier extends StateNotifier<PopularState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  PopularStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(PopularState.initial());

  void getPosts(DateTime date, int page, TimeScale scale) async {
    try {
      state = PopularState.loading();

      final dtos = await _postRepository.getPopularPosts(date, page, scale);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = PopularState.fetched(
        posts: filteredPosts,
        page: page,
        date: date,
        scale: scale,
      );
    } on DatabaseTimeOut catch (e) {
      state =
          PopularState.error(name: "Errors", message: "Something went wrong");
    }
  }

  void refresh() async {
    try {
      state = PopularState.loading();

      final date = DateTime.now();
      final page = 1;
      final scale = TimeScale.day;

      final dtos = await _postRepository.getPopularPosts(date, page, scale);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = PopularState.fetched(
        posts: filteredPosts,
        page: page,
        scale: scale,
        date: date,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  void getMorePosts(
      List<Post> currentPosts, DateTime date, int page, TimeScale scale) async {
    try {
      final nextPage = page + 1;
      final dtos = await _postRepository.getPopularPosts(date, nextPage, scale);
      final settings = await _settingRepository.load();
      final filteredPosts = filter(dtos, settings);

      state = PopularState.fetched(
        posts: currentPosts..addAll(filteredPosts),
        page: nextPage,
        scale: scale,
        date: date,
      );
    } on DatabaseTimeOut catch (e) {}
  }

  // Stream<PopularState> _mapTimeBackwardedToState(_TimeBackwarded event) async* {
  //   var previousDate;
  //   switch (state.selectedTimeScale) {
  //     case TimeScale.day:
  //       previousDate = Jiffy(state.selectedTime).subtract(days: 1);
  //       break;
  //     case TimeScale.week:
  //       previousDate = Jiffy(state.selectedTime).subtract(weeks: 1);
  //       break;
  //     case TimeScale.month:
  //       previousDate = Jiffy(state.selectedTime).subtract(months: 1);
  //       break;
  //     default:
  //       previousDate = Jiffy(state.selectedTime).subtract(days: 1);
  //       break;
  //   }

  //   yield state.copyWith(
  //     selectedTime: previousDate,
  //     isLoadingNew: true,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPopularPosts(
  //         previousDate, state.page, state.selectedTimeScale);
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

  // Stream<PopularState> _mapTimeForwardedToState(_TimeForwarded event) async* {
  //   var nextDate;
  //   switch (state.selectedTimeScale) {
  //     case TimeScale.day:
  //       nextDate = Jiffy(state.selectedTime).add(days: 1);
  //       break;
  //     case TimeScale.week:
  //       nextDate = Jiffy(state.selectedTime).add(weeks: 1);
  //       break;
  //     case TimeScale.month:
  //       nextDate = Jiffy(state.selectedTime).add(months: 1);
  //       break;
  //     default:
  //       nextDate = Jiffy(state.selectedTime).add(days: 1);
  //       break;
  //   }

  //   yield state.copyWith(
  //     selectedTime: nextDate,
  //     isLoadingNew: true,
  //   );

  //   try {
  //     final dtos = await _postRepository.getPopularPosts(
  //         nextDate, state.page, state.selectedTimeScale);
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
}
