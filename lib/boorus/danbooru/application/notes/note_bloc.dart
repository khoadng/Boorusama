// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/common/bloc/bloc.dart';
import 'package:boorusama/core/application/common.dart';

class NoteBloc extends Bloc<NoteEvent, AsyncLoadState<List<Note>>> {
  NoteBloc({
    required NoteRepository noteRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<NoteRequested>(
      (event, emit) async {
        await tryAsync<List<Note>>(
          action: () => noteRepository.getNotesFrom(event.postId),
          onLoading: () => emit(const AsyncLoadState.loading()),
          onFailure: (stackTrace, error) =>
              emit(const AsyncLoadState.failure()),
          onSuccess: (notes) async => emit(AsyncLoadState.success(notes)),
        );
      },
      transformer: debounce(const Duration(milliseconds: 200)),
    );

    on<NotePrefetched>((event, emit) async {
      event.postIds
          .mapIndexed((i, id) => Future.delayed(
                Duration(milliseconds: i * 200),
                () => noteRepository.getNotesFrom(id),
              ))
          // ignore: no-empty-block
          .forEach((t) => t.then((value) {
                // do nothing
                // print(value.length);
              }));
    });

    on<NoteReset>(
      (event, emit) async {
        emit(const AsyncLoadState.initial());
      },
    );
  }
}

@immutable
abstract class NoteEvent extends Equatable {
  const NoteEvent();
}

class NoteRequested extends NoteEvent {
  const NoteRequested({
    required this.postId,
  });
  final int postId;

  @override
  List<Object?> get props => [postId];
}

class NotePrefetched extends NoteEvent {
  const NotePrefetched({
    required this.postIds,
  });
  final List<int> postIds;

  @override
  List<Object?> get props => [postIds];
}

class NoteReset extends NoteEvent {
  const NoteReset();

  @override
  List<Object?> get props => [];
}
