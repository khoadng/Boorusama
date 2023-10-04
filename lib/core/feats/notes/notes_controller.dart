// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
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
    ref.watchConfig;

    return NotesControllerState.initial();
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }

  Future<void> load() async {
    if (state.notes.isEmpty && arg.isTranslated) {
      //FIXME: this looks like a potential bug
      final notes = await ref
          .read(noteRepoProvider(ref.read(currentBooruConfigProvider)))
          .getNotes(arg.id);
      state = state.copyWith(
        notes: notes.lock,
      );
    }
  }
}
