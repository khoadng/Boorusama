// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/e621/e621_provider.dart';
import 'package:boorusama/boorus/e621/feats/notes/e621_note_repository.dart';

final e621NoteRepoProvider = Provider<NoteRepository>((ref) {
  return E621NoteRepositoryApi(
    ref.watch(e621ApiProvider),
  );
});
