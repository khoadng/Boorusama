// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@immutable
class SliverPostGridState extends Equatable {
  const SliverPostGridState({
    required this.currentIndex,
    required this.nextIndex,
  });

  factory SliverPostGridState.initial() => const SliverPostGridState(
        currentIndex: 0,
        nextIndex: 0,
      );

  final int currentIndex;
  final int nextIndex;

  SliverPostGridState copyWith({
    int? currentIndex,
    int? nextIndex,
  }) =>
      SliverPostGridState(
        currentIndex: currentIndex ?? this.currentIndex,
        nextIndex: nextIndex ?? this.nextIndex,
      );

  @override
  List<Object?> get props => [currentIndex, nextIndex];
}

@immutable
abstract class SliverPostGridEvent extends Equatable {
  const SliverPostGridEvent();
}

class SliverPostGridItemChanged extends SliverPostGridEvent {
  const SliverPostGridItemChanged({
    required this.index,
  });
  final int index;

  @override
  List<Object?> get props => [index];
}

class SliverPostGridExited extends SliverPostGridEvent {
  const SliverPostGridExited({
    required this.lastIndex,
  });
  final int lastIndex;

  @override
  List<Object?> get props => [lastIndex];
}

class SliverPostGridBloc
    extends Bloc<SliverPostGridEvent, SliverPostGridState> {
  SliverPostGridBloc() : super(SliverPostGridState.initial()) {
    on<SliverPostGridItemChanged>(
      (event, emit) => emit(state.copyWith(
        currentIndex: event.index,
      )),
      transformer: sequential(),
    );

    on<SliverPostGridExited>(
      (event, emit) => emit(state.copyWith(
        nextIndex: event.lastIndex,
      )),
      transformer: droppable(),
    );
  }
}
