// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_riverpod/all.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/posts/post_repository.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/settings/setting_repository.dart';
import 'package:boorusama/core/application/list_state_notifier.dart';
import '../../black_listed_filter_decorator.dart';
import '../../no_image_filter_decorator.dart';

part 'explore_state.dart';
part 'explore_state_notifier.freezed.dart';

final exploreStateNotifierProvider =
    StateNotifierProvider<ExploreStateNotifier>((ref) {
  final postRepo = ref.watch(postProvider);
  final settingsRepo = ref.watch(settingsProvider.future);
  final filteredPostRepo = BlackListedFilterDecorator(
      postRepository: postRepo, settingRepository: settingsRepo);
  final removedNullImageRepo =
      NoImageFilterDecorator(postRepository: filteredPostRepo);
  final listStateNotifier = ListStateNotifier<Post>();
  return ExploreStateNotifier(removedNullImageRepo, listStateNotifier)
    ..refresh();
});

class ExploreStateNotifier extends StateNotifier<ExploreState> {
  ExploreStateNotifier(
    IPostRepository postRepository,
    ListStateNotifier<Post> listStateNotifier,
  )   : _postRepository = postRepository,
        _listStateNotifier = listStateNotifier,
        super(ExploreState.initial());

  final ListStateNotifier<Post> _listStateNotifier;
  final IPostRepository _postRepository;

  void getMorePosts() async {
    _listStateNotifier.getMoreItems(
      callback: () async {
        final nextPage = state.posts.page + 1;

        final dtos = await state.category.when(
          popular: () => _postRepository.getPopularPosts(
              state.selectedDate, nextPage, state.selectedTimeScale),
          curated: () => _postRepository.getCuratedPosts(
              state.selectedDate, nextPage, state.selectedTimeScale),
          mostViewed: () => _postRepository.getMostViewedPosts(
            state.selectedDate,
          ),
        );
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        return posts;
      },
      onStateChanged: (state) => this.state = this.state.copyWith(
            posts: state,
          ),
    );
  }

  void refresh() async {
    _listStateNotifier.refresh(
      callback: () async {
        final dtos = await state.category.when(
          popular: () => _postRepository.getPopularPosts(
              state.selectedDate, 1, state.selectedTimeScale),
          curated: () => _postRepository.getCuratedPosts(
              state.selectedDate, 1, state.selectedTimeScale),
          mostViewed: () => _postRepository.getMostViewedPosts(
            state.selectedDate,
          ),
        );
        final posts = dtos.map((dto) => dto.toEntity()).toList();

        return posts;
      },
      onStateChanged: (state) {
        if (mounted) {
          this.state = this.state.copyWith(
                posts: state,
              );
        }
      },
    );
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

  void changeCategory(ExploreCategory category) {
    if (state.category != category) {
      state = ExploreState.initial().copyWith(
        category: category,
      );
    }
  }

  void viewPost(Post post) {
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: post,
    );
  }

  void stopViewing() {
    state = state.copyWith(
      lastViewedPost: state.currentViewingPost,
      currentViewingPost: null,
    );
  }
}
