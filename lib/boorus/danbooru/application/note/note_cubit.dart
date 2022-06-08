// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_note_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';

class NoteCubit extends Cubit<AsyncLoadState<List<Note>>> {
  NoteCubit({
    required this.noteRepository,
  }) : super(const AsyncLoadState.initial());

  final INoteRepository noteRepository;

  void getNote(int postId) {
    tryAsync<List<Note>>(
      action: () => noteRepository.getNotesFrom(postId),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onSuccess: (notes) => emit(AsyncLoadState.success(notes)),
    );
  }
}
