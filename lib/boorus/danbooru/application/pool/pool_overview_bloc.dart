import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

class PoolOverviewCategoryChanged extends PoolOverviewEvent {
  const PoolOverviewCategoryChanged({
    required this.category,
  });

  final PoolCategory category;

  @override
  List<Object?> get props => [category];
}

class PoolOverviewOrderChanged extends PoolOverviewEvent {
  const PoolOverviewOrderChanged({
    required this.order,
  });

  final PoolOrder order;

  @override
  List<Object?> get props => [order];
}

class PoolOverviewBloc extends Bloc<PoolOverviewEvent, PoolOverviewState> {
  PoolOverviewBloc()
      : super(const PoolOverviewState(
          category: PoolCategory.series,
          order: PoolOrder.lastUpdated,
        )) {
    on<PoolOverviewCategoryChanged>(
      (event, emit) {
        state.copyWith(
          category: event.category,
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );

    on<PoolOverviewOrderChanged>(
      (event, emit) {
        state.copyWith(
          order: event.order,
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );
  }
}
