// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts.dart';

class NotesControllerState extends Equatable {
  const NotesControllerState({
    required this.notes,
    required this.enableNotes,
    this.alreadyLoaded = false,
  });

  factory NotesControllerState.initial() => NotesControllerState(
        notes: <Note>[].lock,
        enableNotes: true,
      );

  final IList<Note> notes;
  final bool enableNotes;
  final bool alreadyLoaded;

  NotesControllerState copyWith({
    IList<Note>? notes,
    bool? enableNotes,
    bool? alreadyLoaded,
  }) =>
      NotesControllerState(
        notes: notes ?? this.notes,
        enableNotes: enableNotes ?? this.enableNotes,
        alreadyLoaded: alreadyLoaded ?? this.alreadyLoaded,
      );

  @override
  List<Object?> get props => [notes, enableNotes, alreadyLoaded];
}

class NotesControllerNotifier
    extends AutoDisposeFamilyNotifier<NotesControllerState, Post> {
  @override
  NotesControllerState build(Post arg) {
    ref.watchConfigAuth;

    return NotesControllerState.initial();
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }

  Future<void> load() async {
    if (state.isInvalidNoteState(arg)) return;

    if (state.notes.isEmpty && arg.isTranslated) {
      final noteRepo = ref.read(noteRepoProvider(ref.readConfigAuth));

      final notes = await noteRepo.getNotes(arg.id);

      if (notes.isEmpty) return;

      state = state.copyWith(
        notes: notes.lock,
        alreadyLoaded: true,
      );
    }
  }
}

extension NotesControllerStateX on NotesControllerState {
  bool isInvalidNoteState(Post post) =>
      notes.isEmpty && post.isTranslated && alreadyLoaded;
}

class NoteActionButtonWithProvider extends ConsumerWidget {
  const NoteActionButtonWithProvider({
    super.key,
    required this.post,
    required this.noteState,
  });
  final Post post;
  final NotesControllerState noteState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (noteState.isInvalidNoteState(post)) return const SizedBox.shrink();

    return NoteActionButton(
      post: post,
      showDownload: noteState.notes.isEmpty,
      enableNotes: noteState.enableNotes,
      onDownload: () => ref.read(notesControllerProvider(post).notifier).load(),
      onToggleNotes: () => ref
          .read(notesControllerProvider(post).notifier)
          .toggleNoteVisibility(),
    );
  }
}
