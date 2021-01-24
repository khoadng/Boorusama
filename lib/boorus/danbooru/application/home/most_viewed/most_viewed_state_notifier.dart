import 'package:boorusama/boorus/danbooru/application/home/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/i_setting_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

import '../post_filter.dart';

part 'most_viewed_state.dart';
part 'most_viewed_state_notifier.freezed.dart';

final mostViewedStateNotifierProvider =
    StateNotifierProvider<MostViewedStateNotifier>((ref) {
  return MostViewedStateNotifier(ref)..refresh();
});

class MostViewedStateNotifier extends StateNotifier<MostViewedState> {
  final IPostRepository _postRepository;
  final ISettingRepository _settingRepository;

  MostViewedStateNotifier(ProviderReference ref)
      : _postRepository = ref.read(postProvider),
        _settingRepository = ref.read(settingsProvider),
        super(MostViewedState.initial());

  void refresh() async {
    try {
      state = state.copyWith(
        page: 1,
        posts: [],
        postsState: PostState.refreshing(),
      );

      final dtos = await _postRepository.getMostViewedPosts(state.selectedDate);
      final settings = await _settingRepository.load();
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

  void updateDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
    );
  }
}
