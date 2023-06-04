// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/feat/notes/notes.dart';

class PostDetailsNoteState extends Equatable {
  const PostDetailsNoteState({
    required this.notes,
    required this.enableNotes,
  });

  final List<Note> notes;
  final bool enableNotes;

  factory PostDetailsNoteState.initial() => const PostDetailsNoteState(
        notes: [],
        enableNotes: true,
      );

  PostDetailsNoteState copyWith({
    List<Note>? notes,
    bool? enableNotes,
  }) =>
      PostDetailsNoteState(
        notes: notes ?? this.notes,
        enableNotes: enableNotes ?? this.enableNotes,
      );

  @override
  List<Object?> get props => [notes, enableNotes];
}

class PostDetailsNoteNotifier
    extends AutoDisposeFamilyNotifier<PostDetailsNoteState, Post> {
  @override
  PostDetailsNoteState build(Post arg) {
    return PostDetailsNoteState.initial().copyWith(
      notes: ref.watch(danbooruNoteProvider(arg)),
    );
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }
}
