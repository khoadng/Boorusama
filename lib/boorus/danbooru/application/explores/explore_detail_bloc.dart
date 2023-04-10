// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/utils/bloc/bloc.dart';

enum ExploreCategory {
  popular,
  mostViewed,
  hot,
}

@immutable
class ExploreDetailState extends Equatable {
  const ExploreDetailState({
    required this.scale,
    required this.date,
    required this.category,
  });

  factory ExploreDetailState.initial() => ExploreDetailState(
        scale: TimeScale.day,
        date: DateTime.now(),
        category: ExploreCategory.popular,
      );

  final TimeScale scale;
  final DateTime date;
  final ExploreCategory category;

  ExploreDetailState copyWith({
    TimeScale? scale,
    DateTime? date,
    ExploreCategory? category,
  }) =>
      ExploreDetailState(
        scale: scale ?? this.scale,
        date: date ?? this.date,
        category: category ?? this.category,
      );

  @override
  List<Object?> get props => [scale, date, category];
}

@immutable
abstract class ExploreDetailEvent extends Equatable {
  const ExploreDetailEvent();
}

class ExploreDetailDateChanged extends ExploreDetailEvent {
  const ExploreDetailDateChanged(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

class ExploreDetailTimeScaleChanged extends ExploreDetailEvent {
  const ExploreDetailTimeScaleChanged(this.scale);
  final TimeScale scale;

  @override
  List<Object?> get props => [scale];
}

class ExploreDetailBloc extends Bloc<ExploreDetailEvent, ExploreDetailState> {
  ExploreDetailBloc({
    DateTime? initialDate,
    TimeScale? initialScale,
    required ExploreCategory category,
  }) : super(ExploreDetailState(
          scale: initialScale ?? TimeScale.day,
          date: initialDate ?? DateTime.now(),
          category: category,
        )) {
    on<ExploreDetailDateChanged>(
      (event, emit) => emit(state.copyWith(date: event.date)),
      transformer: debounce(const Duration(milliseconds: 200)),
    );
    on<ExploreDetailTimeScaleChanged>(
      (event, emit) => emit(state.copyWith(scale: event.scale)),
      transformer: debounce(const Duration(milliseconds: 350)),
    );
  }
}

class ExploreHotDetailBloc extends ExploreDetailBloc {
  ExploreHotDetailBloc() : super(category: ExploreCategory.hot);
}

class ExplorePopularDetailBloc extends ExploreDetailBloc {
  ExplorePopularDetailBloc() : super(category: ExploreCategory.popular);
}

class ExploreMostViewedDetailBloc extends ExploreDetailBloc {
  ExploreMostViewedDetailBloc() : super(category: ExploreCategory.mostViewed);
}

extension DateTimeX on DateTime {
  DateTime subtractTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).subtract(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).subtract(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).subtract(months: 1).dateTime;
    }
  }

  DateTime addTimeScale(TimeScale scale) {
    switch (scale) {
      case TimeScale.day:
        return Jiffy(this).add(days: 1).dateTime;
      case TimeScale.week:
        return Jiffy(this).add(weeks: 1).dateTime;
      case TimeScale.month:
        return Jiffy(this).add(months: 1).dateTime;
    }
  }
}
