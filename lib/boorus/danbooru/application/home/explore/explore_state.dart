part of 'explore_state_notifier.dart';

@freezed
abstract class ExploreState with _$ExploreState {
  const factory ExploreState({
    @required ListState<Post> posts,
    @required DateTime selectedDate,
    @required TimeScale selectedTimeScale,
    @required ExploreCategory category,
  }) = _ExploreState;

  factory ExploreState.initial() => ExploreState(
        posts: ListState.initial(),
        selectedDate: DateTime.now(),
        selectedTimeScale: TimeScale.day,
        category: ExploreCategory.popular(),
      );
}

@freezed
abstract class ExploreCategory with _$ExploreCategory {
  const factory ExploreCategory.popular() = _Popular;
  const factory ExploreCategory.curated() = _Curated;
  const factory ExploreCategory.mostViewed() = _MostViewed;
}

extension ExploreCategoryX on ExploreCategory {
  String getName() {
    return "${this.toString().split('.').last.replaceAll('()', '').toUpperCase()}";
  }
}
