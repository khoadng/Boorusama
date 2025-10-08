// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/config.dart';
import '../../../core/notes/note/providers.dart';
import '../../../core/notes/note/types.dart';
import '../client_provider.dart';
import 'parser.dart';

final e621NoteRepoProvider = Provider.family<NoteRepository, BooruConfigAuth>((
  ref,
  config,
) {
  final client = ref.watch(e621ClientProvider(config));

  return NoteRepositoryBuilder(
    fetch: (postId) => client
        .getNotes(postId: postId)
        .then((value) => value.map(e621NoteDtoToE621Note).toList())
        .then((value) => value.map(e621NoteToNote).toList())
        .catchError((_) => <Note>[]),
  );
});
