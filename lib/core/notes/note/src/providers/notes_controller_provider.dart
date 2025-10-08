// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../posts/post/post.dart';

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
  }) => NotesControllerState(
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

final notesControllerProvider = NotifierProvider.autoDispose
    .family<NotesControllerNotifier, NotesControllerState, Post>(
      NotesControllerNotifier.new,
    );
