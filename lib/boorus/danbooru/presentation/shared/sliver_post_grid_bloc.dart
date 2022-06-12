// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

@immutable
class SliverPostGridState extends Equatable {
  const SliverPostGridState({
    required this.currentIndex,
  });

  final int currentIndex;

  SliverPostGridState copyWith({
    List<Post>? posts,
    int? currentIndex,
  }) =>
      SliverPostGridState(
        currentIndex: currentIndex ?? this.currentIndex,
      );

  factory SliverPostGridState.initial() =>
      const SliverPostGridState(currentIndex: 0);

  @override
  List<Object?> get props => [currentIndex];
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
  List<Object?> get props => throw UnimplementedError();
}

class SliverPostGridBloc
    extends Bloc<SliverPostGridEvent, SliverPostGridState> {
  SliverPostGridBloc({
    required List<Post> posts,
  }) : super(SliverPostGridState.initial()) {
    on<SliverPostGridItemChanged>((event, emit) {
      emit(state.copyWith(
        currentIndex: event.index,
        posts: posts,
      ));
    });
  }
}
