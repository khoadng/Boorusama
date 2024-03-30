// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/functional.dart';

class NotesControllerState extends Equatable {
  const NotesControllerState({
    required this.notes,
    required this.enableNotes,
    this.alreadyLoaded = false,
  });

  final IList<Note> notes;
  final bool enableNotes;
  final bool alreadyLoaded;

  factory NotesControllerState.initial() => NotesControllerState(
        notes: <Note>[].lock,
        enableNotes: true,
      );

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
