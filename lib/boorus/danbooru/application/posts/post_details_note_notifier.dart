// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/notes.dart';
import 'package:boorusama/core/domain/posts.dart';

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
    extends AutoDisposeFamilyNotifier<PostDetailsNoteState, int> {
  @override
  PostDetailsNoteState build(int arg) => PostDetailsNoteState.initial();

  Future<void> load(Post post) async {
    if (post.isTranslated) {
      state = state.copyWith(
        notes: await _loadNotes(post.id),
      );
    }
  }

  Future<List<Note>> _loadNotes(int postId) =>
      ref.read(noteRepoProvider).getNotesFrom(postId);

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }
}
