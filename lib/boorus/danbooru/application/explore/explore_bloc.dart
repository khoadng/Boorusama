// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore.dart';
import 'package:boorusama/boorus/danbooru/application/post/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class ExploreState extends Equatable {
  const ExploreState({
    required this.popular,
    required this.hot,
    required this.curated,
    required this.mostViewed,
  });

  factory ExploreState.initial() => ExploreState(
        popular: ExploreData.empty(ExploreCategory.popular),
        hot: ExploreData.empty(ExploreCategory.hot),
        curated: ExploreData.empty(ExploreCategory.curated),
        mostViewed: ExploreData.empty(ExploreCategory.mostViewed),
      );

  final ExploreData popular;
  final ExploreData hot;
  final ExploreData curated;
  final ExploreData mostViewed;

  ExploreState copyWith({
    ExploreData? popular,
    ExploreData? hot,
    ExploreData? curated,
    ExploreData? mostViewed,
  }) =>
      ExploreState(
        popular: popular ?? this.popular,
        hot: hot ?? this.hot,
        curated: curated ?? this.curated,
        mostViewed: mostViewed ?? this.mostViewed,
      );

  @override
  List<Object?> get props => [popular, hot, curated, mostViewed];
}

abstract class ExploreEvent extends Equatable {
  const ExploreEvent();
}

class ExploreFetched extends ExploreEvent {
  const ExploreFetched();

  @override
  List<Object?> get props => [];
}

class _CopyState extends ExploreEvent {
  const _CopyState(
    this.state,
    this.category,
  );

  final PostState state;
  final ExploreCategory category;

  @override
  List<Object?> get props => [state, category];
}

class _ChangeDate extends ExploreEvent {
  const _ChangeDate(
    this.category,
    this.date,
  );

  final ExploreCategory category;
  final DateTime date;

  @override
  List<Object?> get props => [date, category];
}

class ExploreBloc extends Bloc<ExploreEvent, ExploreState> {
  ExploreBloc({
    required ExploreRepository exploreRepository,
    required PostBloc popular,
    required PostBloc hot,
    required PostBloc curated,
    required PostBloc mostViewed,
  }) : super(ExploreState.initial()) {
    on<ExploreFetched>((event, emit) async {
      final now = DateTime.now();

      emit(state.copyWith(
        popular: ExploreData.initial(
          category: ExploreCategory.popular,
          date: now,
        ),
        hot: ExploreData.initial(
          category: ExploreCategory.hot,
          date: now,
        ),
        curated: ExploreData.initial(
          category: ExploreCategory.curated,
          date: now,
        ),
        mostViewed: ExploreData.initial(
          category: ExploreCategory.mostViewed,
          date: now,
        ),
      ));

      popular.add(PostRefreshed(
        fetcher: ExplorePreviewFetcher.now(
          now: () => now,
          onDateChanged: (date) =>
              add(_ChangeDate(ExploreCategory.popular, date)),
          category: ExploreCategory.popular,
          exploreRepository: exploreRepository,
        ),
      ));

      curated.add(PostRefreshed(
        fetcher: ExplorePreviewFetcher.now(
          now: () => now,
          onDateChanged: (date) =>
              add(_ChangeDate(ExploreCategory.curated, date)),
          category: ExploreCategory.curated,
          exploreRepository: exploreRepository,
        ),
      ));

      hot.add(PostRefreshed(
        fetcher: ExplorePreviewFetcher.now(
          now: () => now,
          onDateChanged: (date) => add(_ChangeDate(ExploreCategory.hot, date)),
          category: ExploreCategory.hot,
          exploreRepository: exploreRepository,
        ),
      ));

      mostViewed.add(PostRefreshed(
        fetcher: ExplorePreviewFetcher.now(
          now: () => now,
          onDateChanged: (date) =>
              add(_ChangeDate(ExploreCategory.mostViewed, date)),
          category: ExploreCategory.mostViewed,
          exploreRepository: exploreRepository,
        ),
      ));
    });

    on<_CopyState>((event, emit) {
      switch (event.category) {
        case ExploreCategory.popular:
          emit(state.copyWith(
            popular: state.popular
                .copyWith(data: event.state.data.take(20).toList()),
          ));
          break;
        case ExploreCategory.curated:
          emit(state.copyWith(
            curated: state.curated
                .copyWith(data: event.state.data.take(20).toList()),
          ));
          break;
        case ExploreCategory.mostViewed:
          emit(state.copyWith(
            mostViewed: state.mostViewed
                .copyWith(data: event.state.data.take(20).toList()),
          ));
          break;
        case ExploreCategory.hot:
          emit(state.copyWith(
            hot: state.hot.copyWith(data: event.state.data.take(20).toList()),
          ));
          break;
      }
    });

    on<_ChangeDate>((event, emit) {
      switch (event.category) {
        case ExploreCategory.popular:
          emit(state.copyWith(
            popular: state.popular.copyWith(date: event.date),
          ));
          break;
        case ExploreCategory.curated:
          emit(state.copyWith(
            curated: state.curated.copyWith(date: event.date),
          ));
          break;
        case ExploreCategory.mostViewed:
          emit(state.copyWith(
            mostViewed: state.mostViewed.copyWith(date: event.date),
          ));
          break;
        case ExploreCategory.hot:
          emit(state.copyWith(
            hot: state.hot.copyWith(date: event.date),
          ));
          break;
      }
    });

    popular.stream
        .distinct()
        .listen((event) => add(_CopyState(event, ExploreCategory.popular)))
        .addTo(compositeSubscription);

    curated.stream
        .distinct()
        .listen((event) => add(_CopyState(event, ExploreCategory.curated)))
        .addTo(compositeSubscription);

    hot.stream
        .distinct()
        .listen((event) => add(_CopyState(event, ExploreCategory.hot)))
        .addTo(compositeSubscription);

    mostViewed.stream
        .distinct()
        .listen((event) => add(_CopyState(event, ExploreCategory.mostViewed)))
        .addTo(compositeSubscription);
  }

  final compositeSubscription = CompositeSubscription();

  @override
  Future<void> close() {
    compositeSubscription.dispose();

    return super.close();
  }
}

class ExploreData extends Equatable {
  const ExploreData({
    required this.category,
    required this.data,
    required this.date,
    required this.scale,
  });

  factory ExploreData.empty([ExploreCategory? category]) => ExploreData(
        category: category ?? ExploreCategory.popular,
        data: const [],
        date: DateTime(1),
        scale: TimeScale.day,
      );

  factory ExploreData.initial({
    required ExploreCategory category,
    required DateTime date,
  }) =>
      ExploreData(
        category: category,
        data: const [],
        date: date,
        scale: TimeScale.day,
      );

  ExploreData copyWith({
    ExploreCategory? category,
    List<PostData>? data,
    DateTime? date,
    TimeScale? scale,
  }) =>
      ExploreData(
        category: category ?? this.category,
        data: data ?? this.data,
        date: date ?? this.date,
        scale: scale ?? this.scale,
      );

  final ExploreCategory category;
  final List<PostData> data;
  final DateTime date;
  final TimeScale scale;

  @override
  List<Object?> get props => [category, data, date, scale];
}
