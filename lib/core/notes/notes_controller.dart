// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../configs/config.dart';
import '../posts/post/post.dart';
import 'notes.dart';

class NotesControllerState extends Equatable {
  const NotesControllerState({
    required this.enableNotes,
  });

  factory NotesControllerState.initial() => const NotesControllerState(
        enableNotes: true,
      );

  final bool enableNotes;

  NotesControllerState copyWith({
    bool? enableNotes,
  }) =>
      NotesControllerState(
        enableNotes: enableNotes ?? this.enableNotes,
      );

  @override
  List<Object?> get props => [enableNotes];
}

class NotesControllerNotifier
    extends AutoDisposeFamilyNotifier<NotesControllerState, Post> {
  @override
  NotesControllerState build(Post arg) {
    return NotesControllerState.initial();
  }

  void toggleNoteVisibility() {
    state = state.copyWith(
      enableNotes: !state.enableNotes,
    );
  }
}

class NoteActionButtonWithProvider extends ConsumerWidget {
  const NoteActionButtonWithProvider({
    required this.post,
    required this.config,
    super.key,
  });

  final Post post;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noteState = ref.watch(notesControllerProvider(post));
    final allNotes = ref.watch(notesProvider(config));
    final notes = allNotes[post.id] ?? const <Note>[].lock;

    if (allNotes.containsKey(post.id) && notes.isEmpty) {
      return const SizedBox.shrink();
    }

    return NoteActionButton(
      post: post,
      showDownload: notes.isEmpty,
      enableNotes: noteState.enableNotes,
      onDownload: () => ref.read(notesProvider(config).notifier).load(post),
      onToggleNotes: () => ref
          .read(notesControllerProvider(post).notifier)
          .toggleNoteVisibility(),
    );
  }
}
