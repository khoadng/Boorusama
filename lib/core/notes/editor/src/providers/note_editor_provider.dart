// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteEditorState extends Equatable {
  const NoteEditorState({
    this.overlayVisible = true,
  });

  final bool overlayVisible;

  NoteEditorState copyWith({
    bool? overlayVisible,
  }) {
    return NoteEditorState(
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }

  @override
  List<Object?> get props => [overlayVisible];
}

class NoteEditorNotifier extends Notifier<NoteEditorState> {
  @override
  NoteEditorState build() => const NoteEditorState();

  void toggleOverlay() {
    state = state.copyWith(overlayVisible: !state.overlayVisible);
  }
}

final noteEditorProvider =
    NotifierProvider<NoteEditorNotifier, NoteEditorState>(
      NoteEditorNotifier.new,
    );
