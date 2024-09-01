// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';

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
    ref.watchConfig;

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
      final fetcher = ref.readCurrentBooruBuilder()?.noteFetcher;

      if (fetcher == null) return;

      final notes = await fetcher(arg.id);

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
    required this.expanded,
    required this.noteState,
  });
  final Post post;
  final bool expanded;
  final NotesControllerState noteState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (noteState.isInvalidNoteState(post)) return const SizedBox.shrink();

    return NoteActionButton(
      post: post,
      showDownload: !expanded && noteState.notes.isEmpty,
      enableNotes: noteState.enableNotes,
      onDownload: () => ref.read(notesControllerProvider(post).notifier).load(),
      onToggleNotes: () => ref
          .read(notesControllerProvider(post).notifier)
          .toggleNoteVisibility(),
    );
  }
}
