// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';

final noteRepoProvider = Provider<NoteRepository>((ref) {
  throw UnimplementedError();
});

final notesControllerProvider = NotifierProvider.autoDispose
    .family<NotesControllerNotifier, NotesControllerState, Post>(
  NotesControllerNotifier.new,
  dependencies: [
    noteRepoProvider,
    currentBooruConfigProvider,
  ],
);
