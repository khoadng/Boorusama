// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../configs/current.dart';
import '../posts/post/post.dart';
import 'notes.dart';

final notesControllerProvider = NotifierProvider.autoDispose
    .family<NotesControllerNotifier, NotesControllerState, Post>(
  NotesControllerNotifier.new,
  dependencies: [
    currentBooruConfigProvider,
  ],
);

final emptyNoteRepoProvider = Provider<NoteRepository>(
  (_) => const EmptyNoteRepository(),
);
