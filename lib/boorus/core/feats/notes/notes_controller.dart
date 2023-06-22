// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

class NotesControllerState extends Equatable {
  const NotesControllerState({
    required this.notes,
    required this.enableNotes,
  });

  final IList<Note> notes;
  final bool enableNotes;

  factory NotesControllerState.initial() => NotesControllerState(
        notes: <Note>[].lock,
        enableNotes: true,
      );

  NotesControllerState copyWith({
    IList<Note>? notes,
    bool? enableNotes,
  }) =>
      NotesControllerState(
        notes: notes ?? this.notes,
        enableNotes: enableNotes ?? this.enableNotes,
      );

  @override
  List<Object?> get props => [notes, enableNotes];
}

class NotesControllerNotifier
    extends AutoDisposeFamilyNotifier<NotesControllerState, Post> {
  @override
  NotesControllerState build(Post arg) {
    ref.watch(currentBooruConfigProvider);

    return NotesControllerState.initial();
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }

  Future<void> load() async {
    if (state.notes.isEmpty && arg.isTranslated) {
      final notes = await ref.read(noteRepoProvider).getNotes(arg.id);
      state = state.copyWith(
        notes: notes.lock,
      );
    }
  }
}
