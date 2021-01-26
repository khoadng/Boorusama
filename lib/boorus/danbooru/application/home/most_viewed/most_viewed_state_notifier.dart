// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/post_state.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import '../../black_listed_filter_decorator.dart';
import '../../no_image_filter_decorator.dart';

part 'most_viewed_state.dart';
part 'most_viewed_state_notifier.freezed.dart';

final mostViewedStateNotifierProvider =
    StateNotifierProvider<MostViewedStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  return MostViewedStateNotifier(removedNullImageRepo)..refresh();
});

class MostViewedStateNotifier extends StateNotifier<MostViewedState> {
  MostViewedStateNotifier(IPostRepository postRepository)
      : _postRepository = postRepository,
        super(MostViewedState.initial());

  final IPostRepository _postRepository;

  void refresh() async {
    try {
      state = state.copyWith(
        page: 1,
        posts: [],
        postsState: PostState.refreshing(),
      );

      final dtos = await _postRepository.getMostViewedPosts(state.selectedDate);
      final posts = dtos.map((dto) => dto.toEntity()).toList();

      if (mounted) {
        state = state.copyWith(
          posts: posts,
          postsState: PostState.fetched(),
        );
      }
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
