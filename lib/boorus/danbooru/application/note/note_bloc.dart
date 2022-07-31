// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

class NoteBloc extends Bloc<NoteEvent, AsyncLoadState<List<Note>>> {
  NoteBloc({
    required INoteRepository noteRepository,
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

class NoteReset extends NoteEvent {
  const NoteReset();

  @override
  List<Object?> get props => [];
}
