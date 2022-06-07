// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_note_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/note.dart';

class NoteCubit extends Cubit<AsyncLoadState<List<Note>>> {
  NoteCubit({
    required this.noteRepository,
  }) : super(AsyncLoadState.initial());

  final INoteRepository noteRepository;

  void getNote(int postId) {
    TryAsync<List<Note>>(
      action: () => noteRepository.getNotesFrom(postId),
      onLoading: () => emit(AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onSuccess: (notes) => emit(AsyncLoadState.success(notes)),
    );
  }
}
