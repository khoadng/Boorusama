// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/notes/notes.dart';

final danbooruNoteRepoProvider = Provider<NoteRepository>((ref) {
  final api = ref.watch(danbooruApiProvider);
  return NoteRepositoryApi(api);
});

final danbooruNoteProvider =
    NotifierProvider.autoDispose.family<NotesNotifier, List<Note>, Post>(
  NotesNotifier.new,
  dependencies: [
    danbooruNoteRepoProvider,
  ],
);
