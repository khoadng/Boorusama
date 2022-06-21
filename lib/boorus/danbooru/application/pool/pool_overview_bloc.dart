// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

class PoolOverviewState extends Equatable {
  const PoolOverviewState({
    required this.category,
    required this.order,
  });

  final PoolCategory category;
  final PoolOrder order;

  PoolOverviewState copyWith({
    PoolCategory? category,
    PoolOrder? order,
  }) =>
      PoolOverviewState(
        category: category ?? this.category,
        order: order ?? this.order,
      );

  @override
  List<Object?> get props => [category, order];
}

abstract class PoolOverviewEvent extends Equatable {
  const PoolOverviewEvent();
}

class PoolOverviewChanged extends PoolOverviewEvent {
  const PoolOverviewChanged({
    this.category,
    this.order,
  });

  final PoolCategory? category;
  final PoolOrder? order;

  @override
  List<Object?> get props => [category, order];
}

class PoolOverviewBloc extends Bloc<PoolOverviewEvent, PoolOverviewState> {
  PoolOverviewBloc()
      : super(const PoolOverviewState(
          category: PoolCategory.series,
          order: PoolOrder.lastUpdated,
        )) {
    on<PoolOverviewChanged>(
      (event, emit) {
        emit(state.copyWith(
          category: event.category ?? state.category,
          order: event.order ?? state.order,
        ));
      },
      transformer: debounceRestartable(const Duration(milliseconds: 500)),
    );
  }
}
