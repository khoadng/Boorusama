// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/current.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/post/post.dart';

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
